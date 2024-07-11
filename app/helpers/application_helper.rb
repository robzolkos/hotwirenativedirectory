module ApplicationHelper
  def android_download_button(app_url)
    case app_url
    when /play\.google\.com/
      render "download_button", path: app_url, icon: "googleplay", aria: "Link to Google Play Store"
    when /f-droid\.org/
      render "download_button", path: app_url, icon: "fdroid", aria: "Link to F-Droid"
    end
  end
end
