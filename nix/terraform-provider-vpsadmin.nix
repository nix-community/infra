{ buildGoModule, fetchFromGitHub, sources }:
buildGoModule {
  pname = "terraform-provider-vpsadmin";
  version = "latest";
  src = sources.terraform-provider-vpsadmin;
  modSha256 = "sha256-gz+t50uHFj4BQnJg6kOJI/joJVE+usLpVzTqziek2wY=";
  subPackages = [ "." ];
}
