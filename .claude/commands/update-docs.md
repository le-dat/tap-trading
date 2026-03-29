# /update-docs — Update Documentation After Completing a Feature

After completing a feature, perform the following steps:

## 1. Update `docs/changelog.md`
Add new entry at the top of the file with format:
```
## [DATE] — [Brief feature name]
### Added
- [Description of what was added]
### Changed
- [Description of what was changed]
### Fixed
- [Description of what was fixed]
```

## 2. Update `docs/project-status.md`
- Mark ✅ for the completed task in milestones list
- Update "Current Status" section with latest progress
- Note what needs to be done next

## 3. Update `docs/architecture.md` (if needed)
If the added feature changes system architecture:
- Update diagram or data flow description
- Record important technical decisions

## 4. Update `CLAUDE.md` (if needed)
If there are:
- New commands to know
- New patterns to follow
- New bugs encountered and how to fix

After updating, summarize what was changed in the docs.
