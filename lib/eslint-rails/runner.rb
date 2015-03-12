module ESLintRails
  class Runner
    include ActionView::Helpers::JavaScriptHelper

    def initialize(filename)
      @filename = filename || 'application'
    end

    def run
      file_content = Rails.application.assets[@filename].to_s

      eslint_js = Rails.application.assets['eslint'].to_s
      config = ESLintRails::Engine.root.join('config/eslint.json').read

      warning_hashes = ExecJS.eval <<-JS
        function () {
          window = this;
          #{eslint_js};
          return eslint.verify('#{escape_javascript file_content}', #{config});
        }()
      JS
      warning_hashes.map{|hash| ESLintRails::Warning.new(hash)}
    end
  end
end
