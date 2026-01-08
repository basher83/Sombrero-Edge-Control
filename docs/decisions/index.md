<!--
This file is the homepage of your Log4brains knowledge base.
You are free to edit it as you want
-->

# 🏗️ Sombrero Edge Control - Architecture Knowledge Base

**Welcome to the architectural decision log for Sombrero Edge Control** - a comprehensive infrastructure-as-code project for deploying secure, containerized workloads on Proxmox Virtual Environment.

This knowledge base contains all Architecture Decision Records (ADRs) that guide the technical direction and implementation choices for our edge computing infrastructure.

## 📋 What You'll Find Here

### Current ADRs by Category

**🏗️ Infrastructure & Configuration**

- [Separate Files for Terraform-Injected Configurations](20240830-separate-files-terraform-injection.md) - File organization strategy
- [Docker iptables Compatibility](20240831-docker-iptables-firewall.md) - Firewall technology choice

**🔧 Tooling & Deployment**

- [Ansible Post-Deployment Architecture](20250902-ansible-post-deployment-config.md) - Configuration management strategy
- [Ansible Role-First Architecture](20250906-ansible-roles.md) - Operations automation approach

**📚 Documentation & Process**

- [Documentation Structure Reorganization](20250902-documentation-reorganization.md) - Information architecture
- [Lightweight Ansible Collection Scoring](20250906-ansible-collection-scoring-system.md) - Evaluation methodology
- [Thoughts Directory for Knowledge Management](20250110-thoughts-directory-knowledge-management.md) - Operational knowledge capture

**🛠️ Meta-Decisions**

- [Use Log4brains for ADR Management](20250908-use-log4brains-to-manage-the-adrs.md) - Documentation tooling
- [Use Markdown ADRs](20250908-use-markdown-architectural-decision-records.md) - Documentation format

## 🎯 Purpose & Benefits

> An Architectural Decision (AD) is a software design choice that addresses a functional or non-functional requirement that is architecturally significant.

Our ADRs serve to:

- 🚀 **Accelerate Onboarding** - New team members can understand "why" decisions were made
- 🔭 **Prevent Decision Regression** - Historical context prevents repeating past mistakes
- 🤝 **Formalize Decision Process** - Collaborative, documented approach to technical choices
- 📈 **Enable Evolution** - Clear foundation for future architectural changes

## 🔄 ADR Lifecycle

ADRs follow this collaborative workflow:

1. **Draft** → Initial proposal and context gathering
1. **Proposed** → Open for review and discussion
1. **Accepted** → Decision implemented and documented
1. **Deprecated/Superseded** → When better alternatives emerge

## 🛠️ How to Use This Knowledge Base

- **Browse by Category** - Use the left navigation to explore decisions by functional area
- **Search** - Use the search bar to find specific topics or technologies
- **Timeline View** - See decisions in chronological order to understand project evolution
- **Cross-References** - Follow "Links" sections to understand decision relationships

## 📚 Additional Resources

- [Project README](../../README.md) - High-level project overview
- [Infrastructure Documentation](../infrastructure/) - Technical implementation details
- [Deployment Guides](../deployment/) - Operational procedures
- [Log4brains Documentation](https://github.com/thomvaill/log4brains/tree/develop#readme) - Tool documentation

---

_This knowledge base is automatically updated when ADR files are committed to the `main` branch. All decisions are collaborative and follow our established review process._
