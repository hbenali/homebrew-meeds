class Meeds < Formula
  desc "Meeds Public Distribution"
  homepage "https://github.com/meeds-io/meeds"
  url "https://github.com/Meeds-io/meeds/releases/download/1.1.1/meeds-tomcat-standalone-1.1.1.zip"
  mirror "https://repository.exoplatform.org/content/groups/public/io/meeds/distribution/plf-community-tomcat-standalone/1.1.0/plf-community-tomcat-standalone-1.1.0.zip"
  sha256 "6a12de185c882b76b72dfa0e00b2561bc090696f87585d59d8d75d96176b9073"
  license "Apache-2.0"

  bottle :unneeded

  depends_on "openjdk"

  def install
    # Remove Windows scripts
    rm_rf Dir["bin/*.bat"]
    rm_rf Dir["*.bat"]
    # Install files
    prefix.install %w[LICENSE.txt]
    libexec.install Dir["*"]
    (bin/"start_meeds").write_env_script "#{libexec}/start_eXo.sh", JAVA_HOME: Formula["openjdk"].opt_prefix
    (bin/"stop_meeds").write_env_script "#{libexec}/stop_eXo.sh", JAVA_HOME: Formula["openjdk"].opt_prefix

  end

  plist_options manual: "start_meeds"

  def plist
    <<~EOS
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
        <dict>
          <key>Disabled</key>
          <false/>
          <key>Label</key>
          <string>#{plist_name}</string>
          <key>ProgramArguments</key>
          <array>
            <string>#{opt_bin}/catalina</string>
            <string>run</string>
          </array>
          <key>KeepAlive</key>
          <true/>
        </dict>
      </plist>
    EOS
  end

  test do
    ENV["CATALINA_BASE"] = testpath
    cp_r Dir["#{libexec}/*"], testpath
    rm Dir["#{libexec}/logs/*"]

    pid = fork do
      exec bin/"catalina", "start"
    end
    sleep 3
    begin
      system bin/"catalina", "stop"
    ensure
      Process.wait pid
    end
    assert_predicate testpath/"logs/platform.log", :exist?
  end
end