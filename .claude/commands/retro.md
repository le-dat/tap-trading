# /retro — Summarize Work Session

After ending a work session, perform a quick summary.

## Execute:

1. **Look back at what was done** in this session:
   ```bash
   git log --oneline --since="8 hours ago"
   ```

2. **Summarize:**
   - ✅ Completed: [list]
   - 🔄 In progress: [list + status]
   - 🐛 Bugs found but not fixed: [list]
   - 💡 Improvement ideas: [list]

3. **Update `docs/project-status.md`** with:
   - End of session status
   - Next priority steps
   - Any important context to remember for next session

4. **Check if anything needs to be done before exiting:**
   - Uncommitted changes? → Commit or stash
   - Failing tests? → Note it down
   - TODOs in code? → Create GitHub issues

5. **Suggestions for next session:** Where to start?
