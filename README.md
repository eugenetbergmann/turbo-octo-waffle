# turbo-octo-waffle
Reimagination of a ephemeral planning system

## Overview

Turbo-Octo-Waffle is a modern approach to transient task and project management. Designed for teams that need lightweight, flexible planning without the overhead of traditional project management tools.

## Core Concepts

- **Waffles**: Individual tasks or work items
- **Syrup**: Dependencies and relationships between tasks
- **Butter**: Priority and importance modifiers
- **Ephemeral**: Tasks auto-archive after completion

## Getting Started

```bash
# Clone the repository
git clone https://github.com/your-org/turbo-octo-waffle.git
cd turbo-octo-waffle

# Install dependencies
npm install

# Run development server
npm run dev
```

## Architecture

The system separates planning concerns into three layers:
1. **Grid**: Spatial organization of tasks
2. **Flow**: Movement through states (todo → doing → done)
3. **History**: Audit trail of all changes

## API Reference

### Waffle Operations

```javascript
// Create a new waffle
const waffle = await client.createWaffle({
  title: "New task",
  priority: "medium",
  tags: ["frontend"]
});

// Update waffle state
await client.updateWaffle(waffle.id, { state: "doing" });

// Add syrup dependency
await client.addDependency(waffle.id, dependencyId);
```

### Query Endpoints

- `GET /api/waffles` - List all waffles
- `GET /api/waffles?state=todo` - Filter by state
- `GET /api/waffles/:id` - Get single waffle
- `POST /api/waffles` - Create new waffle
- `PUT /api/waffles/:id` - Update waffle
- `DELETE /api/waffles/:id` - Archive waffle

## Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `PORT` | Server port | 3000 |
| `DATABASE_URL` | Database connection string | - |
| `AUTO_ARCHIVE_DAYS` | Days until tasks auto-archive | 30 |
| `MAX_WAFFLES` | Maximum waffles per user | 1000 |

## Deployment

### Docker

```bash
docker build -t turbo-octo-waffle .
docker run -p 3000:3000 turbo-octo-waffle
```

### Environment Variables

```bash
PORT=3000
DATABASE_URL=postgresql://user:pass@localhost/db
AUTO_ARCHIVE_DAYS=30
```

## Contributing

Contributions welcome! See CONTRIBUTING.md for guidelines.
