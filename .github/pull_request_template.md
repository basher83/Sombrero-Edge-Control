## 🎯 Feature Summary
<!-- Provide a brief, clear description of the new feature -->

**Feature Name:** <!-- e.g., Docker Role Enhancement -->
**Related Issue(s):** #<!-- Issue number(s) -->
**Type:** <!-- feat, fix, docs, refactor, test, ci, chore -->

## 📋 Scope Definition
<!-- Explicitly define what IS and IS NOT included in this PR -->

### ✅ In Scope

- [ ] <!-- List specific components/functionality being added -->
- [ ] <!-- Be explicit about boundaries -->

### ❌ Out of Scope

- <!-- List related work intentionally excluded -->
- <!-- Future enhancements to be handled separately -->

## 🔄 Change Type

- [ ] **New Role** - Complete role with tasks, defaults, handlers, meta
- [ ] **Role Enhancement** - Updates to existing role functionality
- [ ] **New Module/Plugin** - Custom Ansible module or plugin
- [ ] **Collection Infrastructure** - galaxy.yml, CI/CD, documentation
- [ ] **Playbook Enhancement** - Updates to playbooks or automation
- [ ] **Documentation** - README, guides, or examples
- [ ] **Testing** - Unit tests, integration tests, or molecule scenarios

## 📝 Detailed Description

### Problem Being Solved
<!-- What specific problem does this feature address? -->

### Solution Approach
<!-- Why did you choose this implementation approach? -->

### Alternative Approaches Considered
<!-- What other solutions did you evaluate and why were they not chosen? -->

## 🧪 Testing Instructions

### Prerequisites

**Required Ansible version:**

```yaml
ansible_version: ">=2.19"
```

**Required collections/dependencies:**

```yaml
collections:
  - community.docker
  - community.general
  - ansible.posix
```

**Test environment requirements:**

- Python 3.8+
- Docker (if container testing required)
- Access to test infrastructure

### How to Test

1. **Install the collection:**

   ```bash
   ansible-galaxy collection install . --force
   ```

1. **Run basic functionality tests:**

   ```bash
   ansible-playbook playbooks/test-feature.yml
   ```

1. **Test specific scenarios:**

   ```bash
   # Add specific test commands here
   ```

### Sample Usage

**Example Playbook:**

```yaml
---
- name: Example usage of new feature
  hosts: automation_servers
  collections:
    - basher83.automation_server
  roles:
    - basher83.automation_server.docker
  tasks:
    - name: Your new functionality
      debug:
        msg: "Feature working!"
```

### Expected Results
<!-- What should happen when the feature works correctly? -->

## 🔄 Collection Impact

### galaxy.yml Changes
<!-- Document any updates to galaxy.yml -->
- [ ] Version bump required
- [ ] New dependencies added
- [ ] Breaking changes introduced

### Role Dependencies
<!-- List roles affected by this change -->
- [ ] Affects: `basher83.automation_server.docker`
- [ ] Affects: `basher83.automation_server.firewall`
- [ ] Affects: `basher83.automation_server.vm_lifecycle`

## ✔️ Checklist

### Collection Quality

- [ ] `ansible-galaxy collection build` succeeds
- [ ] `ansible-galaxy collection install` works
- [ ] Collection follows FQCN standards (`basher83.automation_server.*`)
- [ ] All roles use proper namespace
- [ ] galaxy.yml is valid and complete

### Role Standards

- [ ] Roles include proper `meta/main.yml` with dependencies
- [ ] Default variables are documented in README
- [ ] Role variables follow naming conventions
- [ ] Molecule tests exist and pass (when applicable)
- [ ] Role includes comprehensive README

### Code Quality

- [ ] Code follows Ansible coding standards
- [ ] `ansible-lint` passes with no errors
- [ ] `ansible-test sanity` succeeds
- [ ] No hardcoded values (use variables)
- [ ] Error handling is appropriate
- [ ] Idempotent operations (safe to run multiple times)

### Documentation

- [ ] Role README files updated with new functionality
- [ ] Playbook examples provided and tested
- [ ] Breaking changes documented with migration path
- [ ] Changelog fragment added (`changelogs/fragments/`)
- [ ] Variable documentation complete

### Testing

- [ ] Unit tests added/updated (if applicable)
- [ ] Integration tests added/updated
- [ ] Manual testing completed on target platforms
- [ ] Cross-platform compatibility verified
- [ ] Performance impact assessed

### Compatibility

- [ ] Tested with supported Ansible versions (2.19+)
- [ ] Backwards compatible (or breaking changes documented)
- [ ] Python 3.8+ compatibility verified
- [ ] No new dependency conflicts introduced

## 🚨 Breaking Changes & Risks

### Breaking Changes

- [ ] Role interface changes (variable names, task behavior)
- [ ] Dependency updates requiring user action
- [ ] File/directory structure changes
- [ ] Authentication or authorization changes

### Migration Path
<!-- How do users migrate from old to new version? -->
<!-- Include specific steps and commands -->

### Performance Impact

- [ ] New resource requirements (CPU, memory, disk)
- [ ] Execution time changes
- [ ] Network usage impact
- [ ] Concurrent operation considerations

### Security Considerations

- [ ] Privilege escalation risks
- [ ] Sensitive data handling changes
- [ ] Network security implications
- [ ] Authentication method changes

## 🔌 Dependencies
<!-- List any new dependencies or requirements -->

**New Collections:**

- <!-- community.docker, etc. -->

**New Python Packages:**

- <!-- requests, pyyaml, etc. -->

**New System Packages:**

- <!-- docker, git, etc. -->

**External Services:**

- <!-- APIs, databases, etc. -->

## 📸 Screenshots/Output
<!-- If applicable, add screenshots or command output demonstrating the feature -->

<details>
<summary>✅ Test Output</summary>

```bash
# Paste relevant command output here
ansible-playbook playbooks/test-feature.yml

PLAY [Test Feature] *************************************************************

TASK [basher83.automation_server.docker : Install Docker] *********************
ok: [localhost]

PLAY RECAP *********************************************************************
localhost                  : ok=1    changed=0    unreachable=0    failed=0
```

</details>

## 📚 Additional Context
<!-- Any additional information that helps reviewers -->

**Related Documentation:**

- [Ansible Collection Development Guide](https://docs.ansible.com/ansible/latest/dev_guide/developing_collections.html)
- [Role Development Best Practices](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html)

**Design Decisions:**

- <!-- Explain architectural choices -->
- <!-- Reference ADR documents -->

**External References:**

- <!-- Links to relevant issues, discussions, or documentation -->

## 👥 Reviewers
<!-- Tag relevant reviewers or subject matter experts -->

@<!-- username --> - Please review for <!-- specific expertise -->
@<!-- username --> - Infrastructure expertise needed
@<!-- username --> - Security review required

---
**By submitting this PR, I confirm that:**

- [ ] I have read the Ansible collection development guidelines
- [ ] My code follows the project's style guidelines and Ansible best practices
- [ ] I have performed a self-review of my own code
- [ ] My changes generate no new ansible-lint warnings
- [ ] I have tested the changes on the target platforms
- [ ] All tests pass and documentation is updated
- [ ] Breaking changes are documented with migration instructions
