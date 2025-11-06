---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-07 02:20  
**api-readiness-notes:** UI для Admin Panel. Модерация, player management, analytics, world control. ~390 строк.
---

# UI - Admin Panel System

**Статус:** approved  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-07 02:20  
**Приоритет:** КРИТИЧЕСКИЙ (Security & Moderation!)  
**Автор:** AI Brain Manager

**Микрофича:** UI Admin panel & moderation  
**Размер:** ~390 строк ✅

---

## Краткое описание

**UI Admin Panel** - защищенный интерфейс для администраторов и модераторов.

**Ключевые разделы:**
- ✅ Player Management (управление игроками)
- ✅ Moderation Tools (модерация)
- ✅ Real-Time Analytics (аналитика)
- ✅ World State Control (управление миром)
- ✅ Event Management (события)
- ✅ Audit Log (журнал действий)

---

## Главный Dashboard

### Layout

```
┌─────────────────────────────────────────────────────────────────┐
│ ADMIN PANEL                   [Admin: V]  [Role: SUPER_ADMIN]   │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│ [Dashboard] [Players] [Moderation] [Analytics] [World] [Events] │
│                                                                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│ 📊 REAL-TIME METRICS                                             │
│                                                                   │
│ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐             │
│ │ 👥 Online    │ │ 💬 Reports   │ │ 🚫 Bans      │             │
│ │ 12,543       │ │ 15 Pending   │ │ 3 Today      │             │
│ │ ↑ +523 (1h)  │ │ ⚠️ 3 Urgent   │ │ 1,234 Total  │             │
│ └──────────────┘ └──────────────┘ └──────────────┘             │
│                                                                   │
│ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐             │
│ │ 💰 Economy   │ │ ⚔️ Combat     │ │ 📈 Growth    │             │
│ │ 45.2M Eddies │ │ 234 Active   │ │ +12% (7d)    │             │
│ │ in Market    │ │ Sessions     │ │ New Players  │             │
│ └──────────────┘ └──────────────┘ └──────────────┘             │
│                                                                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│ ⚠️ ALERTS & NOTIFICATIONS                                        │
│                                                                   │
│ 🔴 [URGENT] 3 reports about player "CheatBot123" (aimbot)       │
│ 🟡 [WARNING] Suspicious trading activity detected (10+ players) │
│ 🟢 [INFO] Server maintenance scheduled in 2 hours               │
│                                                                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│ 📋 RECENT ADMIN ACTIONS                                          │
│                                                                   │
│ [2 min ago] Admin "Johnny" banned player "Cheater99" (7d)       │
│ [5 min ago] Admin "V" adjusted currency for "Player123" (+1000) │
│ [12 min ago] Admin "Judy" created event "Double XP Weekend"     │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

---

## Player Management Section

### Player Search & Management

```tsx
const PlayerManagementPanel: React.FC = () => {
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedPlayer, setSelectedPlayer] = useState<Player | null>(null);
  
  return (
    <div className="player-management-panel">
      {/* Search Bar */}
      <div className="search-section">
        <input
          type="text"
          placeholder="Search by username, email, or player ID..."
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          className="player-search-input"
        />
        <button onClick={() => searchPlayers(searchQuery)}>
          Search
        </button>
      </div>
      
      {/* Search Results */}
      {searchResults && (
        <div className="search-results">
          <table className="players-table">
            <thead>
              <tr>
                <th>Player ID</th>
                <th>Username</th>
                <th>Level</th>
                <th>Status</th>
                <th>Last Login</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {searchResults.map(player => (
                <tr key={player.id}>
                  <td>{player.id}</td>
                  <td>
                    <PlayerLink player={player} />
                  </td>
                  <td>Lvl {player.level}</td>
                  <td>
                    <StatusBadge status={player.accountStatus} />
                  </td>
                  <td>{formatRelativeTime(player.lastLoginAt)}</td>
                  <td>
                    <ActionButtons player={player} />
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
      
      {/* Player Detail Modal */}
      {selectedPlayer && (
        <PlayerDetailModal 
          player={selectedPlayer}
          onClose={() => setSelectedPlayer(null)}
        />
      )}
    </div>
  );
};
```

---

## Player Detail Modal

```tsx
const PlayerDetailModal: React.FC<{player}> = ({player}) => {
  return (
    <Modal size="large">
      <div className="player-detail-modal">
        {/* Header */}
        <div className="modal-header">
          <Avatar src={player.avatar} size="large" />
          <div className="player-info">
            <h2>{player.username}</h2>
            <span className="player-id">ID: {player.id}</span>
            <StatusBadge status={player.accountStatus} />
          </div>
        </div>
        
        {/* Tabs */}
        <Tabs>
          <Tab label="Overview">
            <PlayerOverviewTab player={player} />
          </Tab>
          
          <Tab label="Stats">
            <PlayerStatsTab player={player} />
          </Tab>
          
          <Tab label="Inventory">
            <PlayerInventoryTab player={player} />
          </Tab>
          
          <Tab label="History">
            <PlayerHistoryTab player={player} />
          </Tab>
          
          <Tab label="Reports">
            <PlayerReportsTab player={player} />
          </Tab>
        </Tabs>
        
        {/* Admin Actions */}
        <div className="admin-actions">
          <h3>Admin Actions</h3>
          
          <div className="action-buttons">
            <button 
              className="btn-danger"
              onClick={() => showBanModal(player)}
            >
              <BanIcon /> Ban Player
            </button>
            
            <button 
              className="btn-warning"
              onClick={() => kickPlayer(player.id)}
            >
              <KickIcon /> Kick Player
            </button>
            
            <button 
              className="btn-warning"
              onClick={() => showMuteModal(player)}
            >
              <MuteIcon /> Mute Player
            </button>
            
            <button 
              className="btn-primary"
              onClick={() => showGrantItemModal(player)}
            >
              <GiftIcon /> Grant Item
            </button>
            
            <button 
              className="btn-primary"
              onClick={() => showAdjustCurrencyModal(player)}
            >
              <CurrencyIcon /> Adjust Currency
            </button>
            
            <button 
              className="btn-danger"
              onClick={() => showDeleteAccountModal(player)}
            >
              <DeleteIcon /> Delete Account
            </button>
          </div>
        </div>
      </div>
    </Modal>
  );
};
```

---

## Moderation Tools

### Report Queue

```tsx
const ModerationReportsQueue: React.FC = () => {
  const { data: reports } = useModerationReports();
  const [selectedReport, setSelectedReport] = useState<Report | null>(null);
  
  return (
    <div className="moderation-reports-queue">
      {/* Filters */}
      <div className="reports-filters">
        <select>
          <option value="all">All Status</option>
          <option value="pending">Pending</option>
          <option value="in_review">In Review</option>
          <option value="resolved">Resolved</option>
        </select>
        
        <select>
          <option value="all">All Reasons</option>
          <option value="cheating">Cheating</option>
          <option value="harassment">Harassment</option>
          <option value="offensive_name">Offensive Name</option>
          <option value="exploit">Exploit Abuse</option>
        </select>
        
        <button onClick={() => refreshReports()}>
          <RefreshIcon /> Refresh
        </button>
      </div>
      
      {/* Reports List */}
      <div className="reports-list">
        {reports.map(report => (
          <div 
            key={report.id}
            className={`report-card ${report.priority === 'urgent' ? 'urgent' : ''}`}
            onClick={() => setSelectedReport(report)}
          >
            <div className="report-header">
              <span className="report-id">#{report.id}</span>
              <span className={`priority ${report.priority}`}>
                {report.priority === 'urgent' ? '⚠️' : ''} {report.priority}
              </span>
              <span className="status">{report.status}</span>
            </div>
            
            <div className="report-content">
              <div className="reported-player">
                <strong>Reported:</strong> {report.reportedPlayer.username}
              </div>
              <div className="reason">
                <strong>Reason:</strong> {report.reason}
              </div>
              <div className="reporter">
                <strong>Reporter:</strong> {report.reporter.username}
              </div>
              <div className="timestamp">
                {formatRelativeTime(report.createdAt)}
              </div>
            </div>
          </div>
        ))}
      </div>
      
      {/* Report Detail Modal */}
      {selectedReport && (
        <ReportDetailModal 
          report={selectedReport}
          onClose={() => setSelectedReport(null)}
        />
      )}
    </div>
  );
};
```

---

## Analytics Dashboard

```tsx
const AdminAnalyticsDashboard: React.FC = () => {
  const { data: metrics } = useRealtimeMetrics();
  
  return (
    <div className="admin-analytics-dashboard">
      {/* Real-Time Metrics */}
      <div className="metrics-grid">
        <MetricCard
          title="Online Players"
          value={metrics.onlinePlayers}
          change={metrics.onlinePlayersChange}
          icon={<UsersIcon />}
        />
        
        <MetricCard
          title="Active Sessions"
          value={metrics.activeSessions}
          change={metrics.activeSessionsChange}
          icon={<ActivityIcon />}
        />
        
        <MetricCard
          title="Combat Sessions"
          value={metrics.combatSessions}
          icon={<SwordIcon />}
        />
        
        <MetricCard
          title="Economy Activity"
          value={`${metrics.economyActivity.toFixed(1)}M`}
          icon={<CurrencyIcon />}
        />
      </div>
      
      {/* Charts */}
      <div className="charts-section">
        <div className="chart-container">
          <h3>Player Activity (24h)</h3>
          <LineChart data={metrics.playerActivity24h} />
        </div>
        
        <div className="chart-container">
          <h3>Revenue (7d)</h3>
          <BarChart data={metrics.revenue7d} />
        </div>
      </div>
      
      {/* Performance Metrics */}
      <div className="performance-section">
        <h3>Server Performance</h3>
        <div className="performance-metrics">
          <PerformanceMetric
            label="Avg Response Time"
            value={`${metrics.avgResponseTime}ms`}
            threshold={100}
            current={metrics.avgResponseTime}
          />
          
          <PerformanceMetric
            label="DB Connections"
            value={metrics.dbConnections}
            threshold={1000}
            current={metrics.dbConnections}
          />
          
          <PerformanceMetric
            label="Memory Usage"
            value={`${metrics.memoryUsage}%`}
            threshold={80}
            current={metrics.memoryUsage}
          />
        </div>
      </div>
    </div>
  );
};
```

---

## World State Control

```tsx
const WorldStateControlPanel: React.FC = () => {
  const { data: worldState } = useWorldState();
  
  return (
    <div className="world-state-control-panel">
      {/* Region Selector */}
      <div className="region-selector">
        <select>
          <option value="night_city">Night City</option>
          <option value="tokyo">Tokyo</option>
          <option value="moscow">Moscow</option>
          <option value="global">Global</option>
        </select>
      </div>
      
      {/* Current State */}
      <div className="current-state">
        <h3>Current World State</h3>
        
        <div className="flags-list">
          {Object.entries(worldState.flags).map(([key, value]) => (
            <div key={key} className="flag-item">
              <span className="flag-name">{key}</span>
              <span className={`flag-value ${typeof value}`}>
                {String(value)}
              </span>
              <button onClick={() => editFlag(key)}>
                <EditIcon />
              </button>
            </div>
          ))}
        </div>
      </div>
      
      {/* Set Flag */}
      <div className="set-flag-section">
        <h3>Set World Flag</h3>
        
        <form onSubmit={handleSetFlag}>
          <input
            type="text"
            placeholder="Flag name"
            required
          />
          
          <input
            type="text"
            placeholder="Flag value"
            required
          />
          
          <button type="submit">
            Set Flag
          </button>
        </form>
      </div>
      
      {/* Recent Changes */}
      <div className="recent-changes">
        <h3>Recent World State Changes</h3>
        
        <table>
          <thead>
            <tr>
              <th>Timestamp</th>
              <th>Admin</th>
              <th>Flag</th>
              <th>Old Value</th>
              <th>New Value</th>
            </tr>
          </thead>
          <tbody>
            {worldState.recentChanges.map(change => (
              <tr key={change.id}>
                <td>{formatDateTime(change.timestamp)}</td>
                <td>{change.admin.username}</td>
                <td>{change.flagName}</td>
                <td>{String(change.oldValue)}</td>
                <td>{String(change.newValue)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};
```

---

## Event Management

```tsx
const EventManagementPanel: React.FC = () => {
  const { data: events } = useServerEvents();
  
  return (
    <div className="event-management-panel">
      {/* Create Event */}
      <div className="create-event-section">
        <h3>Create Server Event</h3>
        
        <form onSubmit={handleCreateEvent}>
          <input
            type="text"
            placeholder="Event Title"
            required
          />
          
          <textarea
            placeholder="Event Description"
            required
          />
          
          <select name="type">
            <option value="double_xp">Double XP</option>
            <option value="bonus_loot">Bonus Loot</option>
            <option value="special_event">Special Event</option>
            <option value="tournament">Tournament</option>
          </select>
          
          <DateTimePicker
            label="Start Time"
            required
          />
          
          <DateTimePicker
            label="End Time"
            required
          />
          
          <button type="submit">
            Create Event
          </button>
        </form>
      </div>
      
      {/* Active Events */}
      <div className="active-events">
        <h3>Active Events</h3>
        
        {events.active.map(event => (
          <EventCard
            key={event.id}
            event={event}
            actions={['edit', 'end', 'delete']}
          />
        ))}
      </div>
      
      {/* Scheduled Events */}
      <div className="scheduled-events">
        <h3>Scheduled Events</h3>
        
        {events.scheduled.map(event => (
          <EventCard
            key={event.id}
            event={event}
            actions={['edit', 'cancel']}
          />
        ))}
      </div>
    </div>
  );
};
```

---

## Audit Log Viewer

```tsx
const AuditLogViewer: React.FC = () => {
  const { data: logs } = useAuditLogs();
  
  return (
    <div className="audit-log-viewer">
      {/* Filters */}
      <div className="log-filters">
        <select name="admin">
          <option value="all">All Admins</option>
          {admins.map(admin => (
            <option key={admin.id} value={admin.id}>
              {admin.username}
            </option>
          ))}
        </select>
        
        <select name="action">
          <option value="all">All Actions</option>
          <option value="player_banned">Player Banned</option>
          <option value="player_kicked">Player Kicked</option>
          <option value="item_granted">Item Granted</option>
          <option value="currency_adjusted">Currency Adjusted</option>
        </select>
        
        <DateRangePicker />
      </div>
      
      {/* Logs Table */}
      <table className="audit-logs-table">
        <thead>
          <tr>
            <th>Timestamp</th>
            <th>Admin</th>
            <th>Action</th>
            <th>Target</th>
            <th>Details</th>
          </tr>
        </thead>
        <tbody>
          {logs.map(log => (
            <tr key={log.id}>
              <td>{formatDateTime(log.createdAt)}</td>
              <td>{log.admin.username}</td>
              <td>
                <ActionBadge action={log.actionType} />
              </td>
              <td>
                {log.targetType === 'player' && (
                  <PlayerLink playerId={log.targetId} />
                )}
              </td>
              <td>
                <DetailsPopover details={log.details} />
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};
```

---

## Permission-Based UI

```tsx
// Role-based access control
const AdminPanel: React.FC = () => {
  const currentAdmin = useCurrentAdmin();
  
  return (
    <div className="admin-panel">
      <Navigation>
        <NavItem to="/admin/dashboard">Dashboard</NavItem>
        
        {hasPermission(currentAdmin, 'player.view') && (
          <NavItem to="/admin/players">Players</NavItem>
        )}
        
        {hasPermission(currentAdmin, 'moderation.view') && (
          <NavItem to="/admin/moderation">Moderation</NavItem>
        )}
        
        {hasPermission(currentAdmin, 'analytics.view') && (
          <NavItem to="/admin/analytics">Analytics</NavItem>
        )}
        
        {hasPermission(currentAdmin, 'world.manage') && (
          <NavItem to="/admin/world">World State</NavItem>
        )}
        
        {hasPermission(currentAdmin, 'event.create') && (
          <NavItem to="/admin/events">Events</NavItem>
        )}
        
        {hasPermission(currentAdmin, 'audit.view') && (
          <NavItem to="/admin/audit">Audit Log</NavItem>
        )}
      </Navigation>
      
      <Routes>
        <Route path="/dashboard" element={<AdminDashboard />} />
        <Route path="/players" element={<PlayerManagement />} />
        <Route path="/moderation" element={<ModerationTools />} />
        <Route path="/analytics" element={<Analytics />} />
        <Route path="/world" element={<WorldStateControl />} />
        <Route path="/events" element={<EventManagement />} />
        <Route path="/audit" element={<AuditLog />} />
      </Routes>
    </div>
  );
};
```

---

## API Integration

```tsx
// Admin API hooks
const usePlayerSearch = (query: string) => {
  return useQuery({
    queryKey: ['admin-players-search', query],
    queryFn: () => api.get('/api/v1/admin/players/search', { params: { query } }),
    enabled: query.length > 2
  });
};

const useBanPlayer = () => {
  return useMutation({
    mutationFn: (data: BanRequest) => 
      api.post(`/api/v1/admin/players/${data.playerId}/ban`, data),
    onSuccess: () => {
      showNotification('Player banned successfully');
    }
  });
};

const useAuditLogs = () => {
  return useQuery({
    queryKey: ['admin-audit-logs'],
    queryFn: () => api.get('/api/v1/admin/audit-log'),
    refetchInterval: 30000 // Refresh every 30s
  });
};
```

---

## Связанные документы

- [Admin Tools Backend](../../backend/admin/admin-tools-core.md)
- [Anti-Cheat System](../../backend/anti-cheat/anti-cheat-compact.md)
- [Authentication System](../../backend/auth/auth-authorization-security.md)

