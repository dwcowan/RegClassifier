#!/usr/bin/env python3
"""
PDF Extractor for Multi-Column Regulatory Documents

This script extracts text from PDF files with proper handling of:
- Two-column layouts (preserves reading order)
- Mathematical formulas (extracts as LaTeX or text)
- Tables and structured content
- Headers, footers, and page numbers

Usage:
    python extract_regulatory_pdf.py input.pdf output.txt [--format json|text]

Requirements:
    - pdfplumber (column detection, table extraction)
    - pymupdf (formula extraction, advanced text)
    - pillow (image handling)

Install:
    pip install pdfplumber pymupdf pillow
"""

import sys
import json
import argparse
from pathlib import Path
from typing import List, Dict, Any, Optional

try:
    import pdfplumber
except ImportError:
    print("ERROR: pdfplumber not installed. Run: pip install pdfplumber", file=sys.stderr)
    sys.exit(1)

try:
    import fitz  # PyMuPDF
except ImportError:
    print("ERROR: PyMuPDF not installed. Run: pip install pymupdf", file=sys.stderr)
    sys.exit(1)


class RegulatoryPDFExtractor:
    """Extract text from multi-column regulatory PDFs."""

    def __init__(self, pdf_path: str, verbose: bool = True):
        self.pdf_path = Path(pdf_path)
        self.verbose = verbose

        if not self.pdf_path.exists():
            raise FileNotFoundError(f"PDF not found: {pdf_path}")

    def log(self, message: str):
        """Print message if verbose."""
        if self.verbose:
            print(f"[INFO] {message}", file=sys.stderr)

    def extract_with_column_detection(self) -> List[Dict[str, Any]]:
        """
        Extract text using pdfplumber with column detection.

        Returns:
            List of page dictionaries with extracted content.
        """
        pages_data = []

        with pdfplumber.open(self.pdf_path) as pdf:
            self.log(f"Opened PDF: {self.pdf_path.name}")
            self.log(f"Total pages: {len(pdf.pages)}")

            for page_num, page in enumerate(pdf.pages, start=1):
                self.log(f"Processing page {page_num}/{len(pdf.pages)}...")

                page_data = {
                    'page_number': page_num,
                    'text': '',
                    'tables': [],
                    'formulas': [],
                    'metadata': {}
                }

                # Detect if page has columns
                width = page.width
                height = page.height

                # Try to detect two-column layout
                # Strategy: Split page vertically and check text density
                left_bbox = (0, 0, width / 2, height)
                right_bbox = (width / 2, 0, width, height)

                left_crop = page.crop(left_bbox)
                right_crop = page.crop(right_bbox)

                left_text = left_crop.extract_text() or ""
                right_text = right_crop.extract_text() or ""

                # If both columns have substantial text, it's two-column
                if len(left_text.strip()) > 100 and len(right_text.strip()) > 100:
                    # Two-column layout: read left column first, then right
                    page_data['text'] = f"{left_text}\n\n{right_text}"
                    page_data['metadata']['layout'] = 'two_column'
                    self.log(f"  Detected two-column layout on page {page_num}")
                else:
                    # Single column or complex layout: use default extraction
                    page_data['text'] = page.extract_text() or ""
                    page_data['metadata']['layout'] = 'single_column'

                # Extract tables
                tables = page.extract_tables()
                if tables:
                    self.log(f"  Found {len(tables)} tables on page {page_num}")
                    page_data['tables'] = tables

                # Store page dimensions
                page_data['metadata']['width'] = width
                page_data['metadata']['height'] = height

                pages_data.append(page_data)

        return pages_data

    def extract_formulas_with_pymupdf(self) -> List[Dict[str, Any]]:
        """
        Extract mathematical formulas using PyMuPDF.

        PyMuPDF can identify text blocks that are likely formulas
        based on font, size, and positioning.

        Returns:
            List of formula dictionaries.
        """
        formulas = []

        doc = fitz.open(self.pdf_path)
        self.log(f"Scanning for formulas with PyMuPDF...")

        for page_num, page in enumerate(doc, start=1):
            # Get text with formatting information
            blocks = page.get_text("dict")["blocks"]

            for block_num, block in enumerate(blocks):
                if block.get("type") == 0:  # Text block
                    for line in block.get("lines", []):
                        for span in line.get("spans", []):
                            text = span.get("text", "").strip()
                            font = span.get("font", "")
                            size = span.get("size", 0)

                            # Heuristic: Detect formulas
                            # - Contains math symbols
                            # - Uses serif/math fonts
                            # - Different size than body text
                            math_symbols = ['∑', '∫', '∂', '√', '∞', '≈', '≤', '≥', '±', '×', '÷',
                                          '∈', '∉', '⊂', '⊆', '∪', '∩', 'α', 'β', 'γ', 'δ', 'ε',
                                          'θ', 'λ', 'μ', 'π', 'σ', 'τ', 'φ', 'ψ', 'ω', 'Δ', 'Σ', 'Π']

                            has_math_symbols = any(sym in text for sym in math_symbols)
                            has_subscripts = any(c in text for c in ['₀', '₁', '₂', '₃', '₄', '₅', '₆', '₇', '₈', '₉'])
                            has_superscripts = any(c in text for c in ['⁰', '¹', '²', '³', '⁴', '⁵', '⁶', '⁷', '⁸', '⁹'])

                            # Check for formula-like patterns (e.g., "x = y + z")
                            has_equation_pattern = '=' in text and len(text) < 200

                            if has_math_symbols or has_subscripts or has_superscripts or (has_equation_pattern and size > 9):
                                formula = {
                                    'page': page_num,
                                    'text': text,
                                    'font': font,
                                    'size': size,
                                    'bbox': span.get('bbox', [])
                                }
                                formulas.append(formula)

        doc.close()

        if formulas:
            self.log(f"Found {len(formulas)} potential formulas")

        return formulas

    def extract_all(self, include_formulas: bool = True) -> Dict[str, Any]:
        """
        Extract all content from PDF.

        Args:
            include_formulas: Whether to extract formulas (slower).

        Returns:
            Dictionary with all extracted content.
        """
        # Extract text with column detection
        pages = self.extract_with_column_detection()

        # Extract formulas if requested
        formulas = []
        if include_formulas:
            formulas = self.extract_formulas_with_pymupdf()

            # Associate formulas with pages
            for page_data in pages:
                page_num = page_data['page_number']
                page_formulas = [f for f in formulas if f['page'] == page_num]
                page_data['formulas'] = page_formulas

        # Combine all text
        full_text = "\n\n".join(page['text'] for page in pages if page['text'].strip())

        result = {
            'filename': self.pdf_path.name,
            'total_pages': len(pages),
            'full_text': full_text,
            'pages': pages,
            'formulas': formulas,
            'metadata': {
                'two_column_pages': sum(1 for p in pages if p['metadata'].get('layout') == 'two_column'),
                'single_column_pages': sum(1 for p in pages if p['metadata'].get('layout') == 'single_column'),
                'total_tables': sum(len(p['tables']) for p in pages),
                'total_formulas': len(formulas)
            }
        }

        return result

    def save_as_text(self, output_path: str, include_metadata: bool = True):
        """Save extracted content as plain text."""
        result = self.extract_all()

        with open(output_path, 'w', encoding='utf-8') as f:
            if include_metadata:
                f.write(f"=== {result['filename']} ===\n")
                f.write(f"Pages: {result['total_pages']}\n")
                f.write(f"Two-column pages: {result['metadata']['two_column_pages']}\n")
                f.write(f"Tables: {result['metadata']['total_tables']}\n")
                f.write(f"Formulas: {result['metadata']['total_formulas']}\n")
                f.write("=" * 60 + "\n\n")

            f.write(result['full_text'])

        self.log(f"Saved text to: {output_path}")

    def save_as_json(self, output_path: str):
        """Save extracted content as JSON."""
        result = self.extract_all()

        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(result, f, indent=2, ensure_ascii=False)

        self.log(f"Saved JSON to: {output_path}")


def main():
    """Command-line interface."""
    parser = argparse.ArgumentParser(
        description='Extract text from multi-column regulatory PDFs',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Extract to text file
  python extract_regulatory_pdf.py CRR.pdf CRR.txt

  # Extract to JSON with full metadata
  python extract_regulatory_pdf.py CRR.pdf CRR.json --format json

  # Batch process multiple PDFs
  python extract_regulatory_pdf.py *.pdf --output-dir extracted/
        """
    )

    parser.add_argument('input', help='Input PDF file(s)', nargs='+')
    parser.add_argument('--output', '-o', help='Output file (default: input.txt)')
    parser.add_argument('--output-dir', help='Output directory for batch processing')
    parser.add_argument('--format', choices=['text', 'json'], default='text',
                        help='Output format (default: text)')
    parser.add_argument('--no-formulas', action='store_true',
                        help='Skip formula extraction (faster)')
    parser.add_argument('--quiet', '-q', action='store_true',
                        help='Suppress progress messages')

    args = parser.parse_args()

    # Handle batch processing
    if args.output_dir:
        output_dir = Path(args.output_dir)
        output_dir.mkdir(parents=True, exist_ok=True)

        for input_file in args.input:
            input_path = Path(input_file)
            if not input_path.exists():
                print(f"ERROR: File not found: {input_file}", file=sys.stderr)
                continue

            # Determine output filename
            if args.format == 'json':
                output_file = output_dir / f"{input_path.stem}.json"
            else:
                output_file = output_dir / f"{input_path.stem}.txt"

            try:
                extractor = RegulatoryPDFExtractor(input_file, verbose=not args.quiet)

                if args.format == 'json':
                    extractor.save_as_json(str(output_file))
                else:
                    extractor.save_as_text(str(output_file))

                print(f"✓ Processed: {input_file} → {output_file}")

            except Exception as e:
                print(f"ERROR processing {input_file}: {e}", file=sys.stderr)
                continue

    else:
        # Single file processing
        if len(args.input) != 1:
            parser.error("Single file mode requires exactly one input file")

        input_file = args.input[0]

        # Determine output file
        if args.output:
            output_file = args.output
        else:
            input_path = Path(input_file)
            if args.format == 'json':
                output_file = f"{input_path.stem}.json"
            else:
                output_file = f"{input_path.stem}.txt"

        try:
            extractor = RegulatoryPDFExtractor(input_file, verbose=not args.quiet)

            if args.format == 'json':
                extractor.save_as_json(output_file)
            else:
                extractor.save_as_text(output_file)

            print(f"✓ Success! Output: {output_file}")

        except Exception as e:
            print(f"ERROR: {e}", file=sys.stderr)
            sys.exit(1)


if __name__ == '__main__':
    main()
