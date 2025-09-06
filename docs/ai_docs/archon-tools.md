- create_project(title: string, description?: string, github_repo?: string |
  null) => ProjectPurpose: Create a new project with automatic AI assistance,
  generates PRP documentation and initial tasks

  - list_projects() => Project[]Purpose: List all projects with their basic
    information

  - get_project(project_id: string) => ProjectPurpose: Get detailed information
    about a specific project

  - delete_project(project_id: string) => ConfirmationPurpose: Delete a project

  - update_project(project_id: string, title?: string | null, description?:
    string | null, github_repo?: string | null) => ProjectPurpose: Update a
    project's basic information

  - create_task(project_id: string, title: string, description?: string,
    assignee?: string, task_order?: number, feature?: string | null, sources?:
    Array<{url: string, type: string, relevance: string}> | null, code_examples?:
    Array<{file: string, function: string, purpose: string}> | null) =>
    TaskPurpose: Create a new task in a project with optional sources and code
    examples

  - list_tasks(filter_by?: string | null, filter_value?: string | null,
    project_id?: string | null, include_closed?: boolean, page?: number,
    per_page?: number) => Task[]Purpose: List tasks with filtering options by
    status, project, or assignee

  - get_task(task_id: string) => TaskPurpose: Get detailed information about a
    specific task

  - update_task(task_id: string, title?: string | null, description?: string |
    null, status?: string | null, assignee?: string | null, task_order?: number |
    null, feature?: string | null, sources?: Array<Object> | null, code_examples?:
    Array<Object> | null) => TaskPurpose: Update a task's properties including
    status (todo/doing/review/done)

  - delete_task(task_id: string) => ConfirmationPurpose: Delete/archive a task
    (soft delete for audit purposes)

  - create_document(project_id: string, title: string, document_type: string,
    content?: Object | null, tags?: string[] | null, author?: string | null) =>
    DocumentPurpose: Create a new document with automatic versioning (types: spec,
    design, note, prp, api, guide)

  - list_documents(project_id: string) => Document[]Purpose: List all documents for a project

  - get_document(project_id: string, doc_id: string) => DocumentPurpose: Get
    detailed information about a specific document

  - update_document(project_id: string, doc_id: string, title?: string | null,
    content?: Object | null, tags?: string[] | null, author?: string | null) =>
    DocumentPurpose: Update a document's properties

  - delete_document(project_id: string, doc_id: string) => ConfirmationPurpose:
    Delete a document

  - create_version(project_id: string, field_name: string, content: any,
    change_summary?: string | null, document_id?: string | null, created_by?:
    string) => VersionPurpose: Create a new version snapshot of project data
    (field_name: docs/features/data/prd)

  - list_versions(project_id: string, field_name?: string | null) =>
    Version[]Purpose: List version history for a project

  - get_version(project_id: string, field_name: string, version_number: number)
    => VersionPurpose: Get detailed information about a specific version

  - restore_version(project_id: string, field_name: string, version_number:
    number, restored_by?: string) => ConfirmationPurpose: Restore a previous
    version

  - get_project_features(project_id: string) => FeaturesPurpose: Get features
    from a project's features field (functional components and capabilities)

  - perform_rag_query(query: string, source_domain?: string | null, match_count?: number) => SearchResultsPurpose: Search knowledge base for
    relevant content using RAG

  - search_code_examples(query: string, source_domain?: string | null, match_count?: number) => CodeExamplesPurpose: Search for relevant code examples in the knowledge base

  - get_available_sources() => Sources[]Purpose: Get list of available sources in the knowledge base

  - health_check() => HealthStatusPurpose: Check health status of MCP server and dependencies

  - session_info() => SessionInfoPurpose: Get current and active session information
