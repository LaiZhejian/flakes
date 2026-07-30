function install() {}

async function startup() {
  await Zotero.initializationPromise;

  const secretDirectory = Zotero.Prefs.get("flake.secretDirectory");
  if (!secretDirectory) {
    Zotero.logError("Flake Zotero secret directory is not configured");
    return;
  }

  const readSecret = async name =>
    (await Zotero.File.getContentsAsync(PathUtils.join(secretDirectory, name))).trim();

  Zotero.Prefs.set("sync.server.username", await readSecret("username"));
  Zotero.Prefs.set("sync.storage.username", await readSecret("webdav-username"));
  Zotero.Prefs.set("sync.storage.url", await readSecret("webdav-url"));
  Zotero.Prefs.set(
    "ZoteroPDFTranslate.cnkiToken",
    await readSecret("pdf-translate-cnki-token"),
  );
  Zotero.Prefs.set(
    "ZoteroPDFTranslate.secretObj",
    await readSecret("pdf-translate-secret-obj"),
  );

  const password = await readSecret("webdav-password");
  if (password) {
    await Zotero.Sync.Runner.getStorageController("webdav").setPassword(password);
  }
}

function shutdown() {}
function uninstall() {}
