cask "timecamp-reminder" do
  version "1.10.2"
  sha256 "7f81ba28e3ec43656c2ba2b02156e877634fdb2a7bde72407c3f25133fb4281d"

  url "https://api.github.com/repos/vinod-rightmo/timecamp-reminder/releases/assets/746433446",
      header: [
        "Accept: application/octet-stream",
        "Authorization: Bearer #{ENV["HOMEBREW_GITHUB_API_TOKEN"]}",
      ]
  name "TimeCamp Reminder"
  desc "Menu bar reminder to log time in TimeCamp"
  homepage "https://github.com/vinod-rightmo/timecamp-reminder"

  depends_on macos: :ventura
  container type: :zip

  app "TimeCamp Reminder.app"

  uninstall quit: "com.vinodliyanage.timecamp-reminder"
end
