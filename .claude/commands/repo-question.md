---
allowed-tools: Bash(git ls-files:*), Read
description: Answer questions about the project structure and documentation without coding
argument-hint: [Repo question]
---

# Question

Answer the user's question by analyzing the project structure and documentation. This prompt is designed to provide information and answer questions without making any code changes.

## Instructions

- **IMPORTANT: This is a question-answering task only - DO NOT write, edit, or create any files**
- **IMPORTANT: Focus on understanding and explaining existing code and project structure**
- **IMPORTANT: Provide clear, informative answers based on project analysis**
- **IMPORTANT: If the question requires code changes, explain what would need to be done conceptually without implementing**

## Execute

- !`git ls-files` to understand the project structure

## Tool Integration Strategy

- **Initial Analysis**: Always start with !`git ls-files docs/` to establish documentation baseline
- **Targeted Reading**: Use question classification to determine which specific docs to read first
- **Verification**: Cross-reference tool findings against docs/README.md structure before responding

## Read

- @README.md for project overview
- @docs/README.md for project documentation

## Analysis Approach

1. **Documentation Mapping**: Cross-reference question against docs/README.md directory structure
2. **Context-Aware Reading**: Selectively read relevant documentation based on question type:
   - Deployment questions → @docs/deployment/ directory
   - Architecture decisions → @docs/decisions/ directory
   - Troubleshooting → @docs/troubleshooting/ directory
   - Development setup → @docs/development/ directory
   - Infrastructure → @docs/infrastructure/ directory
   - Planning/Strategy → @docs/planning/ directory
3. **ADR Integration**: Check @docs/decisions/ for relevant architectural decisions
4. **Troubleshooting Priority**: Reference @docs/troubleshooting/ for known issues
5. **Quick Start Guidance**: Use Quick Start section for setup/configuration questions

## Question Classification & Documentation Routing

**Deployment/Infrastructure Questions:**

- Primary: @docs/deployment/, @docs/infrastructure/
- Secondary: @docs/decisions/ for architectural context
- Check: @troubleshooting/ for deployment issues

**Development/Setup Questions:**

- Primary: @docs/development/, @docs/ai_docs/
- Secondary: @docs/planning/ansible-refactor/ for tooling decisions
- Check: Quick Start section in @docs/README.md

**Architecture/Design Questions:**

- Primary: @docs/decisions/, @docs/planning/architecture-decisions/
- Secondary: @docs/planning/ansible-refactor/role-specifications.md
- Reference: Project-PRP.md for requirements context

**Troubleshooting/Debugging:**

- Primary: @docs/troubleshooting/
- Secondary: @docs/deployment/smoke-testing-implementation.md
- Check: infrastructure/ for environment-specific issues

## Documentation Quality Assurance

- **Verify Completeness**: Cross-check findings against docs/README.md structure
- **ADR Validation**: Ensure recommendations align with documented architectural decisions
- **Process Alignment**: Confirm suggestions match @docs/deployment/ and @docs/development/ processes
- **Troubleshooting Coverage**: Reference known issues from troubleshooting/ directory

## When Documentation is Incomplete

- Flag gaps in documentation coverage
- Suggest creating/updating documentation for future reference
- Reference most closely related existing documentation
- Note when architectural decisions may need to be made

## Response Structure

1. **Direct Answer** (2-3 sentences)
2. **Supporting Evidence** (cite specific files/docs)
3. **Documentation References** (with relative paths)
4. **Next Steps/Actions** (if applicable)

## Question

$ARGUMENTS
