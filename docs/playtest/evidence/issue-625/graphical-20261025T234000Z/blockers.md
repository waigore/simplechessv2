# Blockers — why the #625 off-device run stopped

Three needs, none of them met in an unattended pass:

1. **A physical phone (or a non-development laptop).** #625 is explicitly the *funded*,
   off-device reading; it exists because every other shipped-build check runs on the
   repository's runner or a desktop. No phone is attached to this machine and the issue is
   assigned to a person who sits at it — the sitting itself (mode pick → a full Shared game →
   two puzzle attempts → background → quit/reopen) is a person at a table, not a script.
2. **A network path from that phone to the build.** The host's own LAN address
   (`192.168.0.119:8625`) times out from the host while `127.0.0.1:8625` answers — macOS
   Application Firewall enabled, no prompt in an unattended run. Serving to a phone needs
   the firewall opened for the trial or a tunnel, which is a setup decision for the owner.
3. **A person's hands.** Frame-rate evidence on a phone, a backgrounded tab, and a quit are
   interactive acts. Scripting them from the same machine would re-create the desktop reading
   #625 exists to replace.

The export, its checks and the firewall evidence are in [builds.md](builds.md) §2–§3.
