# 1. replace versioned generic kernels with unversioned
s|linuxKernel.packages.linux_[0-9_]*\.|linuxPackages.|g
# 2. drop other kernels (hardened, xanmod, zen, etc)
/linuxKernel.packages.linux_\w*/d

# replace versioned with unversioned
s|php\w*Extensions|phpExtensions|g
s|php\w*Packages|phpPackages|g

# replace versioned/jit with unversioned
s|postgresql\w*Packages|postgresqlPackages|g

# replace versioned with the default version
s|python3\w*Packages|python312Packages|g

# drop > 4000 packages that can't be updated
/^rPackages.\w*/d

# drop > 100s of other packages that can't be updated
/haskellPackages.\w*/d
/home-assistant-component-tests.\w*/d
/perl\w*Packages.\w*/d
