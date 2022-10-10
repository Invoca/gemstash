# frozen_string_literal: true

require "spec_helper"

RSpec.describe Gemstash::Logging do
  it "builds a logger in the right place" do
    expect(File.exist?(TEST_LOG_FILE)).to be_truthy
  end

  it "can write using the formatted logger" do
    Gemstash::Logging.logger.error("a formatted message")
    expect(the_log).to include("ERROR - a formatted message")
  end

  it "won't add multiple lines when logging with newlines" do
    Gemstash::Logging.logger.info("a message with a newline\n")
    log_contents = the_log
    expect(log_contents).to include("a message with a newline\n")
    expect(log_contents).to_not include("a formatted message\n\n")
  end

  context "when GEMSTASH_LOG_FORMAT is set to json" do
    before do
      ENV["GEMSTASH_LOG_FORMAT"] = "json"
      the_log
    end

    after do
      ENV["GEMSTASH_LOG_FORMAT"] = ""
      the_log
    end

    it "formats the log in JSON when the environment variable is set" do
      Gemstash::Logging.logger.error("a formatted message")
      expect(the_log).to include({ severity: "ERROR", datetime: Time.now, message: "a formatted message" }.to_json)
    end
  end
end

RSpec.describe Gemstash::Logging::StreamLogger do
  let(:logger) { Gemstash::Logging::StreamLogger.new(Logger::INFO) }
  let(:error_logger) { Gemstash::Logging::StreamLogger.new(Logger::ERROR) }

  it "responds to flush" do
    expect(logger).to respond_to(:flush)
  end

  it "response to sync=" do
    expect(logger).to respond_to(:sync=)
  end

  it "logs with write" do
    logger.write("a message with write")
    expect(the_log).to include("a message with write")
  end

  it "logs with puts" do
    logger.puts("a message with puts")
    expect(the_log).to include("a message with puts")
  end

  it "logs with the level provided" do
    logger.puts("an info message")
    error_logger.puts("an error message")
    log_contents = the_log
    expect(log_contents).to include("INFO - an info message")
    expect(log_contents).to include("ERROR - an error message")
  end
end
