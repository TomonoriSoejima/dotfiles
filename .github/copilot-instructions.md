# RTK — Token-Optimized CLI

**rtk** is a CLI proxy that filters and compresses command outputs, saving 60-90% tokens.

## Rule

Always prefix shell commands with `rtk`. Never run the raw versions of these commands.

### Files
```bash
ls / ls -la                rtk ls .
cat / head / tail          rtk read file.rs
find "*.rs" .              rtk find "*.rs" .
grep "pattern" .           rtk grep "pattern" .
diff file1 file2           rtk diff file1 file2
```

### Git
```bash
git status                 rtk git status
git log -n 10              rtk git log -n 10
git diff                   rtk git diff
git add                    rtk git add
git commit -m "msg"        rtk git commit -m "msg"
git push                   rtk git push
git pull                   rtk git pull
```

### GitHub CLI
```bash
gh pr list                 rtk gh pr list
gh pr view 42              rtk gh pr view 42
gh issue list              rtk gh issue list
gh run list                rtk gh run list
```

### Containers
```bash
docker ps                  rtk docker ps
docker images              rtk docker images
docker logs <c>            rtk docker logs <c>
docker compose ps          rtk docker compose ps
kubectl get pods           rtk kubectl pods
kubectl logs <pod>         rtk kubectl logs <pod>
kubectl get services       rtk kubectl services
```

### Test Runners
```bash
cargo test                 rtk cargo test
go test                    rtk go test
pytest                     rtk pytest
jest                       rtk jest
npm test                   rtk test npm test
```

### Build & Lint
```bash
cargo build                rtk cargo build
cargo clippy               rtk cargo clippy
tsc                        rtk tsc
eslint                     rtk lint
ruff check                 rtk ruff check
```

### AWS
```bash
aws ec2 describe-instances rtk aws ec2 describe-instances
aws logs get-log-events    rtk aws logs get-log-events
aws s3 ls                  rtk aws s3 ls
```

### Data & Misc
```bash
curl <url>                 rtk curl <url>
cat config.json            rtk json config.json
cat app.log                rtk log app.log
env                        rtk env
```

## Meta commands (use directly)
```bash
rtk gain              # Token savings dashboard
rtk gain --history    # Per-command savings history
rtk discover          # Find missed rtk opportunities
rtk proxy <cmd>       # Run raw (no filtering) but track usage
```
