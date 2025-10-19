# Playwright CSV Prompt Demo

A tool that uses Playwright to automate web form interactions by reading values from a CSV file, entering them into prompts, and exporting the results back to CSV format.

## Description

This project automates the process of:
- Reading data from a CSV input file
- Using Playwright to interact with web pages
- Automatically filling form fields/prompts with CSV data
- Capturing and exporting results to a CSV output file

## Prerequisites

- Ruby (version 3.0 or higher recommended)
- Playwright

## Installation

1. Clone this repository:
```bash
   git clone https://github.com/dadachi/playwright_csv_prompt_demo.git
   cd playwright_csv_prompt_demo
```

2. Install dependencies:
```bash
   gem install playwright-ruby-client
   gem install csv
```

## Usage

Run the automation script:
```bash
ruby automation.rb
```

## Input/Output

- **input.csv**: Place your CSV file with the data to be automated in the project directory
- **output.csv**: Results will be exported to a CSV file after automation completes

## License

MIT License

## Contributing

Contributions are welcome! Please fork the repository, make your changes in a new branch, and submit a pull request.
