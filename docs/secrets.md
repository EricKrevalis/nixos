# secrets

setup details i would rather not put in a public repo (a private git identity, the monitor
layout, this machine's audio tweaks) live encrypted with sops-nix. the encrypted files are
committed under `secrets/`, the plaintext never is.

## how decryption works

`.sops.yaml` lists the recipients allowed to decrypt anything under `secrets/`. there are two:

- my personal age key, private half in `~/.config/sops/age/keys.txt`, backed up off the
  machine. it edits and recovers secrets from anywhere and survives a machine dying.
- the host's age key, derived from its ssh host key (`/etc/ssh/ssh_host_ed25519_key`). it
  decrypts automatically at activation, no human in the loop.

every secret is encrypted to both, so the host opens them at boot and i can open them by hand
later. the public halves are safe to commit, only the private halves matter and they stay off
the repo.

## the pattern

sops decrypts at activation, not at nix eval, so a secret cannot be baked into a nix
generated file. instead each secret is a plain config fragment, decrypted to a path, and the
program reads that path itself at runtime:

| secret | holds | decrypts to | pulled in by |
|--------|-------|-------------|--------------|
| `ssh-work` | a private git identity | `/run/secrets/ssh-work` | ssh `Include` |
| `sway-outputs` | monitor layout | `/run/secrets/sway-outputs` | sway `include` |
| `wireplumber-priority` | audio device priorities | `/etc/wireplumber/wireplumber.conf.d/` | wireplumber |
| `wireplumber-declutter` | audio device cleanup | `/etc/wireplumber/wireplumber.conf.d/` | wireplumber |

the wiring is in `hosts/desktop/configuration.nix` (the `sops.secrets` block) and
`hosts/desktop/home.nix` (the includes). each secret stores the fragment under a single `conf`
key, pulled out with `key = "conf"`.

## editing a secret

```bash
nix-shell -p sops --run 'sops secrets/<file>.yaml'
```

sops opens the plaintext in your editor, re-encrypts on save. needs your personal key at
`~/.config/sops/age/keys.txt`. the next rebuild picks up the change.

## adding a new machine

1. rebuild so openssh generates the host key.
2. get its age public key:
   ```bash
   nix-shell -p ssh-to-age --run 'ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub'
   ```
3. add it to `.sops.yaml` under `keys` with a `&hostname` anchor and reference it in the
   `creation_rules` age list.
4. re-encrypt so the new host becomes a recipient, run from a machine that can already
   decrypt:
   ```bash
   nix-shell -p sops --run 'for f in secrets/*.yaml; do sops updatekeys "$f"; done'
   ```

## the personal key

generated once, not tied to any machine:

```bash
mkdir -p ~/.config/sops/age
nix-shell -p age --run 'age-keygen -o ~/.config/sops/age/keys.txt'
```

back up `keys.txt` to the work drive and a password manager. it is the only thing that can
recover every secret if a machine is lost, the repo never holds it.

## ssh user keys

public identities are declarative in `flake.nix` common as `sshIdentities`, a map of git host
to key filename. `home/basic.nix` renders an ssh config block per entry, each with
`IdentitiesOnly yes` so the agent never offers the wrong key. adding a public service is one
line:

```nix
sshIdentities = {
  "github.com" = "id_ed25519_github";
};
```

private identities do not go in `common` (it is public). they live in the `ssh-work` secret
above and get pulled into `~/.ssh/config` via `programs.ssh.includes`.

keys themselves are never in the repo, regenerate per machine:

```bash
ssh-keygen -t ed25519 -C "Eric Krevalis <eric.krevalis@gmail.com>" -f ~/.ssh/id_ed25519_github
```

upload the `.pub` to the service, then test with `ssh -T`.
