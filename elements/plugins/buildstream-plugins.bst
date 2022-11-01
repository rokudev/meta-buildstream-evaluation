kind: junction
# lol we can't specify a git source because these plugins provide it!
# sources:
# - kind: git
#   url: github-public:apache/buildstream-plugins.git
#   track: master
#   ref: 4acd6f3cd00de867fd08ae8e784c7b7c97bf3e27
sources:
- kind: tar
  url: github-static:apache/buildstream-plugins/archive/refs/tags/1.95.3.tar.gz
  ref: a75ab61f8ef26e12fecdcb421d34018bfd8ceaa2414e1918f496553e8cab9497
