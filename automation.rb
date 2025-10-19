require 'playwright'
require 'csv'

class SimplePromptAutomation
  def initialize(input_csv, output_csv, html_file)
    @input_csv = input_csv
    @output_csv = output_csv
    @html_file = File.expand_path(html_file)
    @user_data_dir = File.expand_path('./user-data-dir')
    @results = []

    unless File.exist?(@html_file)
      raise "HTML file not found: #{@html_file}"
    end
  end

  def run
    puts "Starting automation..."
    puts "HTML: #{@html_file}"
    puts

    Playwright.create(playwright_cli_executable_path: 'npx playwright') do |playwright|
      context = playwright.chromium.launch_persistent_context(
        @user_data_dir,
        headless: false
      )

      input_data = CSV.read(@input_csv, headers: true, encoding: 'UTF-8')
      puts "Processing #{input_data.length} rows...\n\n"

      input_data.each_with_index do |row, index|
        puts "[#{index + 1}/#{input_data.length}] #{row['name']}"

        # 各行ごとに新しいページを作成
        page = context.new_page
        result = process_row(page, row.to_h)
        page.close

        @results << result
        puts "  Status: #{result['status']}\n\n"
      end

      save_results
      context.close
    end

    print_summary
  end

  private

  def process_row(page, row)
    result = row.dup

    begin
      # Set up event handler BEFORE loading the page
      handler = ->(dialog) {
        if dialog.type == 'prompt'
          value = row['name'] || ''
          puts "  Input: #{value}"
          dialog.accept(promptText: value)
        else
          # Accept confirm and alert dialogs
          dialog.accept
        end
      }

      page.on('dialog', handler)

      # Reload the page for each row to reset state
      file_url = "file://#{@html_file}"
      page.goto(file_url, waitUntil: 'domcontentloaded')

      page.click('#startButton')
      sleep 2  # Wait for dialog and output

      if page.query_selector('#output')
        result['output'] = page.inner_text('#output').strip
      end

      result['status'] = 'success'
      result['timestamp'] = Time.now.strftime('%Y-%m-%d %H:%M:%S')

    rescue => e
      puts "  Error: #{e.message}"
      result['status'] = 'error'
      result['error'] = e.message
    end

    result
  end

  def save_results
    return if @results.empty?

    headers = @results.first.keys

    CSV.open(@output_csv, 'w', encoding: 'UTF-8') do |csv|
      csv << headers
      @results.each { |result| csv << headers.map { |h| result[h] } }
    end

    puts "Results saved: #{@output_csv}"
  end

  def print_summary
    total = @results.length
    success = @results.count { |r| r['status'] == 'success' }

    puts "\n" + "=" * 40
    puts "Total:   #{total}"
    puts "Success: #{success}"
    puts "Failed:  #{total - success}"
    puts "=" * 40
  end
end

# 実行
if __FILE__ == $0
  automation = SimplePromptAutomation.new(
    'input.csv',
    'output.csv',
    './test.html'
  )

  automation.run
end