# Orchestration User Guide

How users experience orchestrated work and how to get the best results.

## How It Works

You describe what you want. Complex work happens elegantly behind the scenes. Results arrive synthesized and actionable.

The system processes requests through distinct phases:
1. **Understanding** - Grasping what you need
2. **Clarifying** - Asking questions when scope is fuzzy
3. **Executing** - Parallel work behind the scenes
4. **Synthesizing** - Combining results into clear answers

## Task Complexity Tiers

### Quick Tasks
Direct, immediate answers. No orchestration overhead.
```
"What's the syntax for async/await in Python?"
→ Direct answer in seconds
```

### Standard Tasks
Progress updates, parallel analysis, synthesized results.
```
"Review this PR for issues"
→ "Analyzing code quality, security, and performance..."
→ Unified review with prioritized findings
```

### Large Projects
Structured phases, clear milestones, comprehensive synthesis.
```
"Implement user authentication"
→ Phase 1: Research existing patterns
→ Phase 2: Design architecture
→ Phase 3: Parallel implementation
→ Phase 4: Integration and testing
```

## Getting Better Results

### Be Specific
```
BAD: "Fix the bug"
GOOD: "Fix the login timeout bug in auth.ts that occurs after 30 seconds of inactivity"
```

### Provide Context
```
BAD: "Add caching"
GOOD: "Add Redis caching to the user API endpoints. We're using Next.js 14 with Prisma and PostgreSQL. Current response times are ~500ms, target is <100ms."
```

### Clarify Priorities
```
BAD: "Improve the app"
GOOD: "Improve the checkout flow. Priority order: reliability > performance > UX polish"
```

### Share Constraints
```
BAD: "Build a dashboard"
GOOD: "Build a dashboard using React with shadcn/ui. Must work on mobile. No external analytics libraries due to privacy requirements."
```

## Interactive Elements

### When Questions Appear

The system asks questions when choices genuinely affect outcomes:
- **Destructive operations** - Confirmation before irreversible changes
- **Ambiguous scope** - Multiple valid interpretations exist
- **Preference-dependent** - No objectively "correct" answer
- **Trade-off decisions** - Performance vs maintainability, etc.

### Adjusting Mid-Stream

You can always:
- Interrupt to change direction
- Request more detail on specific aspects
- Ask for different approaches
- Provide additional context

## What to Expect

### Progress Updates
Natural language updates, not technical jargon:
```
"Got a few threads running on this..."
"Early results coming in. Looking good."
"Pulling it together now..."
```

### Results Format
Synthesized, prioritized, actionable:
```
## Summary
[Executive overview]

## Key Findings
[Most important insights first]

## Recommendations
[Clear next steps]

## Details
[Supporting evidence when relevant]
```

### Milestone Celebrations
Natural acknowledgment of significant progress:
```
"Phase 1 complete. Strong foundation in place."
"Security review passed with flying colors."
```

## Tips for Complex Requests

### Break Down Epics
If you have a very large request, consider breaking it into phases yourself:
```
"Let's start with Phase 1: Research existing auth patterns in our codebase"
```

### Provide Examples
When you have preferences, show them:
```
"I want error handling like this: [example]. Apply this pattern across all API routes."
```

### Reference Existing Code
Point to what you like:
```
"Use the same component structure as UserProfile.tsx for the new Settings page"
```

### State Non-Negotiables
Be explicit about requirements:
```
"Must maintain backwards compatibility with v1 API. Must have >80% test coverage."
```
