{
  programs.uv = {
    enable = true;
    settings = {
      pip.index-url = "https://pypi.mirrors.ustc.edu.cn/simple/";
      index = [
        {
          url = "https://pypi.mirrors.ustc.edu.cn/simple/";
          default = true;
        }
      ];
      pip.link-mode = "clone";
      # python-install-mirror = "https://github.com/astral-sh/python-build-standalone/releases/download";
      python-install-mirror = "https://hub.gitmirror.com/https://github.com/astral-sh/python-build-standalone/releases/download";
    };
  };
}
