DEFAULTS(
    DefaultTTL("1"), // 1 = automatic
    CF_PROXY_DEFAULT_OFF
);

var REG_NONE = NewRegistrar("none");
var DSP_CLOUDFLARE = NewDnsProvider("cloudflare");

// # For each github page, create a CNAME alias to nix-community.github.io
var nix_community_github_pages = [
    // keep-sorted start
    "nur",
    // keep-sorted end
];

var hosts = {
    // keep-sorted start block=yes
    "build01": {
        ipv4: "65.21.139.242",
        ipv6: "2a01:4f9:3b:2946::1"
    },
    "build02": {
        ipv4: "65.21.133.211",
        ipv6: "2a01:4f9:3b:41d9::1"
    },
    "build03": {
        ipv4: "162.55.14.99",
        ipv6: "2a01:4f8:2190:2698::2"
    },
    "build04": {
        ipv4: "65.109.107.32",
        ipv6: "2a01:4f9:3051:3962::2"
    },
    "build05": {
        ipv4: "65.109.82.88",
        ipv6: "2a01:4f9:3051:5066::1"
    },
    "darwin01": {
        ipv4: "49.12.162.22",
        ipv6: "2a01:4f8:d1:5716::2"
    },
    "darwin02": {
        ipv4: "49.12.162.21",
        ipv6: "2a01:4f8:d1:5715::2"
    },
    "web01": {
        ipv4: "46.226.105.188",
        ipv6: "2001:4b98:dc0:43:f816:3eff:fec9:5764"
    },
    // keep-sorted end
};

var cnames = {
    // keep-sorted start
    "aarch64-build-box": "build05",
    "alertmanager": "web01",
    "build-box": "build01",
    "buildbot": "build03",
    "darwin-build-box": "darwin01",
    "docker": "nix-community.docker.scarf.sh.", // Used by nix-community/nixpkgs-docker
    "hydra": "build03",
    "landscape": "web01",
    "nixpkgs-update-cache": "build02",
    "nixpkgs-update-logs": "build02",
    "nl.meet": "nixnl.codeberg.page.",
    "nur-update": "web01",
    "prometheus": "web01",
    "temp-cache": "build03",
    // keep-sorted end
};

var records = [];

for (var p in nix_community_github_pages) {
    records.push(CNAME(nix_community_github_pages[p], "nix-community.github.io."));
}

for (var h in hosts) {
    records.push(A(h, hosts[h].ipv4));
    records.push(AAAA(h, hosts[h].ipv6));
}

for (var c in cnames) {
    records.push(CNAME(c, cnames[c]));
}

D("nix-community.org",
    REG_NONE,
    DnsProvider(DSP_CLOUDFLARE),

    records,

    // blocks other CAs from issuing certificates for the domain
    CAA("@", "issue", "letsencrypt.org"),

    // "cannot create CNAME record for bare domain", ALIAS -> CNAME
    ALIAS("@", "nix-community.github.io."),
    CNAME("www", "nix-community.github.io."),

    MX("@", 50, "fb.mail.gandi.net."),
    MX("@", 10, "spool.mail.gandi.net."),

    SPF_BUILDER({
        label: "@",
        parts: [
            "v=spf1",
            "include:_mailcust.gandi.net",
            "-all"
        ]
    }),

    TXT("_github-challenge-nix-community-org", "2eee7c1945"),
    TXT("_github-pages-challenge-nix-community", "6d236784300b9b1e80fdc496b7bfce"),
    TXT("_scarf-sh-challenge-nix-community.docker", "5GVHX2INP2W7WLQKNFML"),
);
