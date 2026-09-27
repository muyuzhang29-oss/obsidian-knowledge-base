/**
 * Local Homepage
 * On startup, open the configured note once the workspace is ready.
 */
const DEFAULT_HOME = "00-工作台/00-主页";

module.exports = class LocalHomepagePlugin {
  onload() {
    this.settings = Object.assign({ home: DEFAULT_HOME, openMode: "replace" }, this.loadDataSync());
    this.app.workspace.onLayoutReady(async () => {
      await this.openHome();
    });
  }

  onunload() {}

  loadDataSync() {
    // data.json is optional; plugin loads fine without it
    try {
      const fs = require("fs");
      const path = require("path");
      const p = path.join(this.manifest.dir, "data.json");
      if (fs.existsSync(p)) {
        return JSON.parse(fs.readFileSync(p, "utf8"));
      }
    } catch (e) {}
    return {};
  }

  async openHome() {
    const home = (this.settings && this.settings.home) || DEFAULT_HOME;
    const file = this.app.metadataCache.getFirstLinkpathDest(home, "");
    if (!file) return;
    // Prefer replacing the active leaf so we always end on the homepage
    const leaf = this.app.workspace.getLeaf(false);
    if (leaf) {
      await leaf.openFile(file, { active: true });
      this.app.workspace.setActiveLeaf(leaf, { focus: true });
    }
  }
};
