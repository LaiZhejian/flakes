{ ... }:

let
  plist = body: ''
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
    ${body}
    </dict>
    </plist>
  '';
  root = ".config/alfred/Alfred.alfredpreferences/preferences";
in
{
  home.file = {
    "${root}/prefs.plist".text = plist ''
      <key>location</key>
      <string>China</string>
    '';

    "${root}/appearance/options/prefs.plist".text = plist ''
      <key>hidehat</key>
      <true/>
      <key>showOnScreen</key>
      <integer>1</integer>
    '';

    "${root}/features/clipboard/prefs.plist".text = plist ''
      <key>autoPaste</key>
      <false/>
      <key>clearKeywordEnabled</key>
      <false/>
      <key>hotkey</key>
      <dict>
        <key>key</key>
        <integer>8</integer>
        <key>mod</key>
        <integer>393216</integer>
        <key>string</key>
        <string>C</string>
      </dict>
      <key>snippetsAtTop</key>
      <false/>
      <key>snippetsWhenSearching</key>
      <false/>
      <key>viewerKeywordEnabled</key>
      <false/>
    '';

    "${root}/features/defaultresults/prefs.plist".text = plist ''
      <key>fallbacksMode</key>
      <integer>1</integer>
      <key>showContacts</key>
      <false/>
      <key>showDocuments</key>
      <true/>
      <key>showFolders</key>
      <true/>
    '';

    "${root}/features/terminal/prefs.plist".text = plist ''
      <key>application</key>
      <integer>1</integer>
      <key>prefix</key>
      <integer>2</integer>
    '';

    "${root}/features/webbookmarks/prefs.plist".text = plist ''
      <key>browsermode</key>
      <integer>1</integer>
      <key>mode</key>
      <integer>1</integer>
    '';

    "${root}/local/07c156787d15db03fb41085b73c018f68ef4bf40/hotkey/prefs.plist".text = plist ''
      <key>default</key>
      <dict>
        <key>key</key>
        <integer>49</integer>
        <key>mod</key>
        <integer>524288</integer>
        <key>string</key>
        <string> </string>
      </dict>
    '';

    "${root}/local/07c156787d15db03fb41085b73c018f68ef4bf40/keyboard/prefs.plist".text = plist ''
      <key>locale</key>
      <string>com.apple.keylayout.ABC</string>
    '';
  };
}
