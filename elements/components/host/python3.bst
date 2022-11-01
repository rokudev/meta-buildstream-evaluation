kind: autotools

(@):
- include/host-component.yml
- elements/components/common/python3.yml

variables:
  python_inst: "%{install-root}%{bindir}"
