{ self, ... }:
{
  imports = [
    self.modules.darwin.common
    self.modules.darwin.remote-builder
    self.modules.shared.deploy
  ];

  # set options defined by us
  deploy.user = "m1";
  deploy.hostName = "51.159.120.155";
}
