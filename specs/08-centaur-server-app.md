# Module 08: Snek Centaur Server Frontend

## Requirements

### 8.1 Scope and Runtime Placement

**08-REQ-001**: This module shall define the behavioural requirements of the web application served by a Snek Centaur Server ([02-REQ-004], [02-REQ-030]). The application is the single human-facing interface for the Snek Centaur Platform, encompassing both team-internal competitive operation (heuristic configuration, bot parameters, live gameplay, team replay) and platform-wide cross-team concerns (team management, room management, game spectating, platform replay, profiles, leaderboards, API key management). There is no separate "Game Platform" web application.

**08-REQ-002**: The application shall be served by the Snek Centaur Server runtime. It shall require authentication before exposing any functionality beyond a sign-in control and public, non-user-specific information (e.g., the public leaderboard per §8.19).

**08-REQ-003**: The application shall execute as a browser client that communicates with (a) the Snek Centaur Server runtime for real-time subscriptions to in-memory bot-framework state it does not read directly from Convex, (b) the Convex deployment for reads and mutations against Centaur state ([06]) and platform-wide state ([05]) per [02-REQ-039], and (c) a game's SpacetimeDB instance via OIDC-validated access token per [02-REQ-038] when a game is live or being spectated.

**08-REQ-004**: A single Snek Centaur Server may host multiple Centaur Teams. The application shall present team-scoped views (heuristic configuration, bot parameters, live gameplay, team replay) in the context of a specific hosted Centaur Team, and shall present platform-wide views (room browsing, profiles, leaderboard) independent of any specific team.

**08-REQ-005**: The application shall expose a well-known HTTP endpoint at `/.well-known/snek-game-invite` that receives game invitation payloads from Convex at game start per [05-REQ-032b]. The endpoint shall accept the invitation on behalf of the invited Centaur Team, receive the per-Centaur-Team game credentials, and use those credentials for all subsequent bot-participant interactions with the game's SpacetimeDB instance.

---

### 8.2 Authentication and Authorization

**08-REQ-006**: The application shall require Google OAuth authentication of the human using the same human identity type defined in [03]. It shall not maintain its own independent credential store. Unauthenticated requests to any page of the application other than those exempted by [08-REQ-002] shall be refused.

**08-REQ-007**: After authentication, the application shall resolve the authenticated identity to a user record per [05-REQ-004] and [05-REQ-005]. All subsequent UI actions shall be attributed to that user record for the duration of the session.

**08-REQ-008**: The application shall gate affordances that are restricted to the Captain role — in particular the Captain-only control affordances of §8.14 and the Captain-only affordances of §8.4 (heuristic configuration) and §8.5 (bot parameters) — on the authenticated human's current Captain status as read from [05] via [06]. Captain status changes observed through subscription shall take effect in the UI without requiring the operator to reload the page.

**08-REQ-009** *(negative)*: The application shall never issue a SpacetimeDB access token on its own. Access tokens for a game are obtained through the Convex-mediated issuance path of [05-REQ-035] and presented to SpacetimeDB by the browser.

**08-REQ-009a** *(negative)*: The application shall not store, display, or transmit the plaintext of any SpacetimeDB access token, API key, or other credential material except during the single creation-time disclosure of an API key plaintext per [05-REQ-051] and [03-REQ-034].

**08-REQ-009b**: The application shall provide a sign-out control that terminates the user's session on the client and revokes any client-held session tokens. After sign-out, the UI shall return to the unauthenticated state.

**08-REQ-009c**: When the authenticated human holds the platform admin role ([05-REQ-065]), the application shall expose admin-specific affordances as defined in §8.21. Admin status shall be evaluated from the user record and shall take effect without page reload.

---

### 8.3 Navigation and Page Structure

**08-REQ-010**: The application shall provide a persistent global navigation surface from which the authenticated user can reach each of the following top-level destinations: the home view (§8.3a), the Rooms browser (§8.6), the Teams browser (§8.5a), the user's own Player Profile (§8.18), the global Leaderboard (§8.19), and API Key Management (§8.20). Team-scoped navigation targets (heuristic configuration, bot parameters, game history, live operator interface) shall be accessible within the context of a specific hosted Centaur Team.

**08-REQ-011**: When any hosted Centaur Team of which the user is a member has a game in the `playing` status ([05-REQ-027]), the navigation surface shall make the live operator interface for that team prominent such that an operator arriving at the application is not required to search the navigation to find the active game.

**08-REQ-012**: The application shall not present a page for live gameplay when the relevant Centaur Team has no game in the `playing` status. Attempts to navigate to the live interface under those conditions shall be refused with an explanatory empty state.

**08-REQ-013**: Navigating into the replay viewer shall occur from the game history page (§8.10) or from a direct link (§8.17c). The replay viewer shall not appear as a standalone top-level navigation target.

---

### 8.3a Home View

**08-REQ-010a**: The application shall present, as the authenticated user's home view, at minimum: the list of Centaur Teams of which the user is a current member (per [05-REQ-011]), the list of rooms the user has recently visited, and the list of games currently in progress (status `playing` per [05-REQ-028]) in which any of the user's Centaur Teams are participating. Each listed item shall link directly to its corresponding detailed view.

---

### 8.4 Heuristic Configuration Page

**08-REQ-014**: The heuristic configuration page shall be scoped to a specific hosted Centaur Team. It shall display every Drive type and every Preference registered with that Centaur Team's Snek Centaur Server, sourced from the team's heuristic default configuration ([06-REQ-005]) via [06-REQ-032]'s read surface.

**08-REQ-015**: For each registered Preference, the page shall display and allow editing of: (a) whether the Preference is active on new snakes by default and (b) its default portfolio weight ([06-REQ-006]).

**08-REQ-016**: For each registered Drive type, the page shall display and allow editing of: (a) its default portfolio weight when added to a snake, (b) its `nickname` for UI display, and (c) pinning status in the Drive dropdown presented during Drive management ([06-REQ-007], §8.13). The Captain may reorder the `pinnedHeuristics` array and assign nicknames to Drives from this page. *(Amended per 08-REVIEW-005 resolution: ordinal position replaced with nickname and pinning controls.)*

**08-REQ-017**: Mutations to team-scoped heuristic defaults initiated from this page shall be routed through the Centaur state function contract surface ([06-REQ-030]) and shall be rejected by that surface if the authenticated caller is not the Captain of the owning Centaur Team ([06-REQ-008], [06-REQ-031]). The application shall surface any such rejection to the operator. Non-Captain team members may view the heuristic configuration page in read-only mode. *(Amended per 08-REVIEW-001 resolution: team-scoped heuristic default mutations are Captain-only.)*

**08-REQ-018**: The page shall make explicit to the operator that edits affect defaults for future games only and shall not retroactively affect any game currently in progress ([06-REQ-009]). The concrete UI affordance by which this is communicated is a design-phase decision.

**08-REQ-019** *(negative)*: The heuristic configuration page shall not permit mutations to any per-snake or per-game state. It operates exclusively on team-scoped heuristic defaults. Only the Captain may edit these defaults; other team members see a read-only view. *(Amended per 08-REVIEW-001 resolution: Captain-only for team-scoped default mutations.)*

---

### 8.5 Bot Parameters Page

**08-REQ-020**: The bot parameters page shall be scoped to a specific hosted Centaur Team. It shall display and allow editing of the team's bot parameter record ([06-REQ-011]), comprising at minimum the softmax global temperature and the **automatic submission time allocation** — the team-level turn deadline parameter used by the bot framework's submission process per [07-REQ-044] / [07-REQ-045]. *(Amended per 08-REVIEW-011 resolution.)*

**08-REQ-021**: Mutations initiated from this page shall be routed through the Centaur state function contract surface ([06-REQ-030]) and rejected if the caller is not the Captain of the owning Centaur Team ([06-REQ-012], [06-REQ-031]). Non-Captain team members may view the bot parameters page in read-only mode. *(Amended per 08-REVIEW-001 resolution: Captain-only for bot parameter mutations.)*

**08-REQ-022**: The page shall make clear to the operator that all `global_centaur_params` values — the softmax temperature and the automatic submission time allocation — take effect on the next game the team enters, not on any game currently in progress. At game start, these defaults are copied into game-scoped state per [06-REQ-040a] and are thereafter independent of the team defaults. *(Amended per 08-REVIEW-002 and 08-REVIEW-011 resolutions.)*

**08-REQ-023** *(negative)*: The bot parameters page shall not expose any parameter that is a game-configuration parameter owned by [05-REQ-023]. Game-configuration parameters are set in the room lobby (§8.8).

---

### 8.5a Teams Browser

**08-REQ-023a**: The application shall provide a Teams browser that lists all Centaur Teams known to the platform per [05-REQ-008], with at minimum the team's name, display colour, and current Captain. Each listed team shall link to that team's public profile (§8.18a).

---

### 8.5b Team Management

**08-REQ-023b**: The application shall provide a Team Management view accessible to every current member of a Centaur Team. The view shall display at minimum the team's name, display colour, current Captain, current members with their roles, the team's designated coaches per [05-REQ-067], and the nominated server domain together with its latest health status per [05-REQ-009] and [02-REQ-029].

**08-REQ-023c**: The application shall permit any authenticated user to create a new Centaur Team per [05-REQ-008]. On creation, the creating user shall become the team's Captain per [05-REQ-011].

**08-REQ-023d**: The Team Management view shall expose, exclusively to the team's current Captain, affordances to mutate team identity (name, display colour), to set or update the team's nominated server domain (`nominatedServerDomain` per [05-REQ-014]), to add or remove human members (per [05-REQ-012]), to add or remove coaches per [05-REQ-067] (via the `addCoach` / `removeCoach` mutations), and to transfer the Captain role to another current member (per [05-REQ-012]).

**08-REQ-023e**: The Team Management view shall, while a team is participating in any game whose status is `playing`, visibly disable the mutating affordances of [08-REQ-023d] that are frozen by [05-REQ-013], and shall explain to the user that the affordance is temporarily unavailable due to a game in progress.

**08-REQ-023f** *(negative)*: The Team Management view shall not expose any affordance for configuring bot parameters, Drive portfolios, heuristic defaults or overrides, snake operator assignment, or any other Centaur-subsystem state. These are the exclusive domain of the team-scoped operator pages (§8.4, §8.5). The view may display a navigation link directing the user to those pages.

---

### 8.6 Room Browser and Creation

**08-REQ-024a**: The application shall provide a Room Browser that lists every room persisted by [05-REQ-016], with at minimum: the room name, the room's optional owner (per [05-REQ-017]), the number of Centaur Teams currently enrolled, and whether the room has a game currently in status `playing` per [05-REQ-028].

**08-REQ-024b**: The Room Browser shall support filtering and searching the listed rooms by room name. Any additional filter criteria shall be a design decision; requirements level mandates only name-based search.

**08-REQ-024c**: The Room Browser shall expose an affordance by which any authenticated user may create a new room per [05-REQ-019]. Room creation shall require at minimum a room name; the creating user shall become the room's owner. The UI shall treat the resulting room creation as a mutation against Convex per [08-REQ-100].

**08-REQ-024d**: Every listed room in the Room Browser shall link directly to the Room Lobby view (§8.8) for that room.

---

### 8.7 Game History Page

**08-REQ-024**: The game history page shall be scoped to a specific hosted Centaur Team. It shall list completed games in which the authenticated human was either (a) a member of the owning team at the time of the game (per the game's participating-team snapshot of [05-REQ-029]) or (b) a current member of the owning team, in reverse chronological order.

**08-REQ-025**: Each listing shall display at minimum: room name, date, opponent teams, the team's result (win/loss/draw — subject to resolution of score semantics per [05-REVIEW-006]), and final scores ([05-REQ-038]). Listing data shall be sourced from [05]'s read surface.

**08-REQ-026**: Selecting a listing shall open the replay viewer (§8.15) for that game. The replay viewer entry point from the game history page shall default to the team-perspective sub-turn view.

**08-REQ-027** *(negative)*: The game history page shall not expose games for teams the authenticated human has no relationship with. A user has a relationship with a team's game if they were a member of that team at the time of the game (per the participating-team snapshot) or are a current member of that team.

---

### 8.8 Room Lobby

**08-REQ-027a**: The application shall provide a Room Lobby view for every room listed in the Room Browser. The Room Lobby view shall display at minimum: the room's current owner (or the no-owner state per [05-REQ-017]), the room's current game-configuration parameter values per [05-REQ-023], the set of Centaur Teams currently enrolled in the room per [05-REQ-016], and the readiness state of each enrolled team.

**08-REQ-027b**: The Room Lobby view shall be accessible to every authenticated user. Users who are neither the room owner nor members of an enrolled team shall see the lobby in a read-only form and shall have no mutating affordance.

**08-REQ-027c**: The Room Lobby view shall expose, exclusively to the administrative actor for the room defined by [05-REQ-017] (the owner, or any authenticated user when there is no owner), affordances to edit every game-configuration parameter of [05-REQ-023] within its defined range, to invite or remove Centaur Teams from enrolment, to abdicate ownership per [05-REQ-018], and to start the game per [05-REQ-031].

**08-REQ-027d**: The Room Lobby view's parameter-editing affordance shall enforce each parameter's type and range by refusing to submit values outside the acceptable range per [05-REQ-023], providing inline feedback to the user before any mutation is dispatched. This client-side enforcement shall be treated as a user-experience affordance only; the authoritative enforcement remains with Convex per [05-REQ-023].

**08-REQ-027e**: The Room Lobby view's parameter-editing affordance shall honour the conditional-parameter semantics of [05-REQ-025]: parameters whose meaning is conditional on a gating parameter shall be visually gated on that parameter and, when gating parameters are off, shall not block the user from persisting the dependent value but shall communicate that the dependent value is currently inactive.

**08-REQ-027f**: The Room Lobby view shall expose, exclusively to the Captain of an enrolled Centaur Team, affordances to mark that team ready and to unmark that team ready, consistent with the Captain-only ready-check semantics of [05-REQ-031]. To other team members, the readiness state shall be visible as a read-only indicator with no mutating affordance. *(Amended per 08-REVIEW-013 resolution: ready/unready is Captain-only, matching the upstream Captain-only authorization fixed by 05-REVIEW-007.)*

**08-REQ-027g**: The Room Lobby view shall expose, exclusively to members of an enrolled Centaur Team, an affordance to ping the team's nominated Snek Centaur Server's healthcheck per [02-REQ-029] and [05-REQ-009], surfacing the result to the lobby view.

**08-REQ-027h**: The Room Lobby view shall enable the game-start affordance of [08-REQ-027c] only when the room has at least two enrolled Centaur Teams per [05-REQ-020] and every enrolled team has been marked ready. When the affordance is disabled, the view shall communicate to the administrative actor which precondition is currently unmet.

**08-REQ-027i**: The Room Lobby view shall provide a **Board Preview** affordance that renders a miniature visualisation of the board geometry — including the placement of fertile tiles, hazards, and snake starting territories — derived from the not-yet-started game's current game-configuration parameter values. The preview shall be generated by the Convex board-generation preview mutation defined by [05-REQ-032b], which re-runs `generateBoardAndInitialState()` from the shared engine codebase ([02-REQ-035]) inside Convex on each parameter edit and persists the result onto the not-yet-started game's configuration document. The web client shall receive the regenerated preview reactively via Convex's reactive query model and shall render it directly; the application shall not run any board-generation algorithm client-side. The regeneration cadence (e.g., debouncing of rapid parameter edits) is a design-level concern. *(Amended per 08-REVIEW-014 resolution: Convex's preview mutation is the sole authority for board generation; ratifies the upstream config-on-game architecture of [05-REQ-022] and [05-REQ-032b].)*

**08-REQ-027j**: The Board Preview shall expose an affordance by which the administrative actor may **lock in** the currently-displayed preview as the starting layout for the next launch of this game. The lock-in semantics are: (a) every preview generation by [05-REQ-032b] writes the resulting starting state onto the not-yet-started game record's configuration document, regardless of lock-in status; (b) a separate `boardPreviewLocked: boolean` flag on the same game record indicates whether [05-REQ-032] step 2 will reuse the persisted starting state (true) or regenerate from a fresh seed at game-launch initiation (false); (c) when unlocked, the regenerated starting state is not surfaced to any configuration-mode UI — it becomes visible only when delivered to operators by SpacetimeDB once the game enters `playing` status. The Room Lobby view shall expose toggle affordances to set and clear the `boardPreviewLocked` flag via the Convex mutations defined by [05-REQ-032b]. *(Amended per 08-REVIEW-015 resolution: lock-in is a flag on the game record, persistence is unconditional on every regeneration.)*

**08-REQ-027k** *(negative)*: The Board Preview shall not stage, commit, or otherwise affect any currently-playing game in the room. Board Preview affects only the next game-launch initiation of the not-yet-started game record being configured, consistent with the immutable-parameter-snapshot rule of [05-REQ-024].

**08-REQ-027l**: The Room Lobby view shall, when the room has a game whose status is `playing`, provide a direct link from the lobby to the Live Spectating view of that game per §8.16.

---

### 8.9 Live Operator Interface — Principles

**08-REQ-028**: The live operator interface shall be scoped to a specific hosted Centaur Team that has a game in the `playing` status. It shall default to AI control of all owned snakes. On entry to the interface for a fresh game, every owned snake shall be in automatic mode (`manualMode = false` in its selection record, [06-REQ-018]) and the bot framework shall be staging moves for it per [07-REQ-044].

**08-REQ-029**: Selecting a snake in the interface shall not, by itself, place that snake in manual mode. Selection is a view-only operation that makes the snake the subject of the move interface, Drive management, decision breakdown, and worst-case world preview, but does not remove the snake from the automatic submission pipeline of [07].

**08-REQ-030**: Manual mode for a snake shall be entered exclusively by (a) the currently selecting operator checking the manual checkbox of §8.13 or (b) the currently selecting operator selecting a concrete direction via the move interface, which auto-sets the manual flag as a side effect per [06-REQ-025]. Exiting manual mode shall occur exclusively by that operator unchecking the manual checkbox, returning the snake to automatic mode immediately such that [07]'s submission pipeline resumes staging for it on its next scheduled pass.

**08-REQ-031**: The interface shall reflect [07]'s compute scheduling principle that compute follows attention: automatic-mode snakes receive continuous scheduled compute, currently-selected manual-mode snakes receive high-priority compute, and unselected manual-mode snakes receive compute last ([07-REQ-040]). This requirement is behavioural on [07]; the UI shall not add extra scheduling logic of its own.

---

### 8.10 Live Operator Interface — Header

**08-REQ-032**: The header of the live operator interface shall display at minimum: the current turn number, the team clock countdown, the team's remaining time budget, the measured network latency to the team's SpacetimeDB instance, a Convex-hosted presence display of other operators currently connected to the same game from the same team along with each connected operator's current ready-state per [06-REQ-040b] (per §8.12), and — conditionally, per §8.14 — the Captain control affordances. *(Amended per 08-REVIEW-011 resolution.)*

**08-REQ-033**: The team clock countdown shall be presented with sufficient precision to convey imminent deadline: the concrete presentation of seconds-to-one-decimal and a warning state below a sub-one-second threshold is the informal spec's proposal and is the minimum required resolution. When the team's turn has been declared over ([01-REQ-039]) the countdown shall be replaced by a "turn submitted" indicator and shall not flicker back to a countdown while the other team(s) finish their declarations.

**08-REQ-034** *(removed per 08-REVIEW-011 resolution; number reserved for stable cross-references)*: Per-turn coordination state is rendered as per-operator ready-state in the operator presence display per [08-REQ-032] and [06-REQ-040b].

**08-REQ-035**: The presence display shall show each other currently-connected operator on the team by their display name and a per-operator colour that is stable within the game's lifetime and is the same colour used for that operator's selection shadow on the board (§8.13). Presence state shall be sourced from a Convex-hosted presence mechanism; the design phase should use the `@convex-dev/presence` library. *(Amended per 08-REVIEW-004 resolution: presence is Convex-hosted.)*

**08-REQ-036**: The network latency indicator shall be a client-measured round-trip time against the team's SpacetimeDB subscription and shall not require any new Convex or Centaur-state field to support it. The exact measurement methodology is a design-phase decision.

---

### 8.11 Live Operator Interface — Board Display, Selection, and Move Interface

**08-REQ-037**: The board display shall render the full current board with: grid lines; all terrain types ([01]) including hazard cells and fertile tiles; all items currently on the board (food, invulnerability potions, invisibility potions); all currently-alive snakes with team colour fill, a per-snake letter designation rendered at the head, and the snake's current length rendered at the neck segment.

**08-REQ-038**: The board display shall render snake effect states ([01]) such that an invulnerability level greater than zero is indicated by a distinctive (e.g. blue) outline on the snake and an invulnerability level less than zero by a distinctive (e.g. red) outline, and such that invisibility is indicated by a translucent/shimmer rendering visible to members of the owning team only ([04]'s RLS visibility rules; [01]'s invisibility semantics). The interface shall not reveal invisibility states of snakes belonging to other teams.

**08-REQ-039**: The board display shall render the current selection state ([06-REQ-018]) as a per-snake selection glow in the colour of the operator who holds the selection. Multiple concurrent selections on distinct snakes by distinct operators shall each render in their respective operators' colours.

**08-REQ-040**: The board display shall render, for the currently-selected owned snake, per-direction move candidate highlighting on the four adjacent cells where each candidate cell is coloured by the bot's current stateMap score for that direction (highest score to lowest using a monotone colour ramp). If no stateMap entry is currently defined for a candidate direction ([07-REQ-049]), that candidate shall be rendered in a distinct neutral state that is visually distinguishable from any score value.

**08-REQ-041**: The board display shall render the currently-staged move for each owned snake with a distinctive marker (e.g. purple border) on the destination cell. The marker shall update without page reload as the staged move changes, whether the change originated from the bot's submission pipeline ([07-REQ-044]) or from an operator action on any connected client.

**08-REQ-042**: Snake selection shall be initiated by clicking the body of an owned snake whose selection the caller is eligible to take per [06-REQ-024]. Selection shall be terminated by pressing Escape or by selecting a different snake. Selecting a snake currently selected by a different operator shall present a displacement confirmation that, upon explicit operator confirmation, issues a selection mutation with the displacement flag set ([06-REQ-022]). Without confirmation, the current selection shall remain with its existing holder.

**08-REQ-043** *(negative)*: The application shall not display, construct, or allow interaction with a direction-candidate for a snake the operator does not currently hold a selection on. All move-staging and Drive-management affordances are gated on the caller being the current selector of the snake being acted on ([06-REQ-025]).

**08-REQ-044**: The move interface shall provide four direction buttons (Up, Down, Left, Right), each labelled with that direction's current stateMap score ([07-REQ-035]) and coloured consistently with the board display's candidate highlighting. Each direction button shall be pre-set to reflect the currently-staged direction for the selected snake (whether staged by the bot or by a human), and direction buttons whose direction is immediately lethal ([01-REQ-044a], [01-REQ-044b]) shall be visibly disabled but shall remain selectable as last-resort candidates per [07-REQ-019].

**08-REQ-045**: Selecting a direction — via click on a direction button or via the keyboard arrow keys while the board has focus — shall simultaneously (a) stage that direction in SpacetimeDB via the staged-move mechanism ([02-REQ-011]) as an operator-originated move, (b) auto-set the snake's manual-mode flag to true per [06-REQ-025], and (c) trigger the worst-case world preview of §8.11a for that direction.

**08-REQ-046**: Staged moves shall be freely changeable at any moment before the team's turn is declared over ([01-REQ-039]); the interface shall not expose a separate "commit" action. The operator shall be made aware by affordance design that each direction selection temporarily stages that direction, so that exploring a direction is not distinguishable to the game engine from committing to it until the turn ends.

**08-REQ-047**: The manual checkbox shall be displayed whenever an owned snake is selected, shall reflect the current value of the snake's manual-mode flag ([06-REQ-018]), and shall be editable by the current selector only. Checking the box shall set the flag to true without staging a new move (the currently-staged move, bot or human, is locked). Unchecking the box shall set the flag to false, at which point [07]'s automatic submission pipeline resumes staging for the snake.

---

### 8.11a Live Operator Interface — Worst-Case World Preview

**08-REQ-048**: When an owned snake is selected and a direction is selected (whether via direction button or arrow key), the board display shall additionally render the worst-case simulated world for that (snake, direction) pair, as read from the computed display state of [06-REQ-026]. Current positions of all snakes shall remain rendered solidly and the worst-case simulated positions shall be rendered as translucent overlays.

**08-REQ-049**: Annotations computed against the worst-case world — such as the Voronoi-style territory overlay the informal spec references, and any other team-configured annotations — shall be rendered against the worst-case world rather than against the current board. They shall be sourced from the `annotations` field of the computed display state ([06-REQ-026]).

**08-REQ-050**: The worst-case world preview shall update reactively as the bot framework writes new computed display state snapshots ([07-REQ-039]), so that an operator who leaves a direction selected while compute proceeds sees the worst-case world evolve in place.

**08-REQ-051**: When no direction is selected, or when no computed display state exists yet for the selected snake, the worst-case world preview shall not render and the board shall show only the current board state.

---

### 8.11b Live Operator Interface — Decision Breakdown Table

**08-REQ-059**: The interface shall render, for the currently-selected owned snake, a per-direction decision breakdown table showing one row per heuristic (Drive or Preference) active on that snake. Each row shall display at minimum: the heuristic's name, its raw normalised output in the worst-case world ([06-REQ-026]'s `heuristicOutputs` field), its current portfolio weight, its weighted contribution to the direction's score, and its relative impact on the direction's total score.

**08-REQ-060**: The decision breakdown shall update reactively as computed display state snapshots are written by the framework and as the operator switches which direction is selected.

---

### 8.12 Live Operator Interface — Per-Operator Ready-State and Turn Submission

*(Section rewritten per 08-REVIEW-011 resolution.)*

**08-REQ-061**: The live operator interface shall expose a per-operator **ready-state toggle** for each authenticated operator currently connected to the team's game session. The toggle is a binary flag — `ready` or `not-ready` — owned exclusively by the operator who toggles it, persisted in [06]'s `operator_ready_state` table per [06-REQ-040b], and reactive across all connected team members via the subscription of [06-REQ-043]. Each operator may toggle their own ready-state freely throughout the turn; no other operator (and no Captain) may toggle a given operator's ready-state on their behalf. *(Amended per 08-REVIEW-011 resolution.)*

**08-REQ-062**: Unanimous operator readiness — every currently-connected operator on the team having set their ready-state to `ready` for the current turn — is a **necessary precondition** for the Snek Centaur Server's automatic turn submission process ([07-REQ-044] / [07-REQ-045]) to call SpacetimeDB's `declare_turn_over` reducer ([04] §2.5). The rules governing when (within the window where this precondition holds) the automatic submission process declares the turn over are defined in [07-REQ-044] / [07-REQ-045]. This precondition is **passive**: its becoming true does not trigger any positive flush, immediate-submit, or out-of-band declaration; it merely permits the automatic submission process to finalise according to its own rules. If the team has zero currently-connected operators, the precondition is unsatisfied and declaration via this path is deferred until at least one operator is connected and ready. Ready-state is reset to `not-ready` for every operator at the start of each new turn (i.e., on the publish of the next authoritative pre-turn board state per [04]). The Captain's manual turn-submit affordance ([08-REQ-065]) is an **independent override** path that bypasses this precondition entirely — it immediately calls `declare_turn_over` regardless of any other operator's ready-state and triggers the flush-suppression behaviour of [07-REQ-045a]. Expiry of the team's chess clock ([01-REQ-039]) similarly bypasses this precondition.

**08-REQ-063**: An operator's ready-state shall remain editable throughout the turn — toggling from `ready` back to `not-ready` is permitted at any time before the team's turn is declared over and shall immediately rescind that operator's contribution to the unanimity condition of [08-REQ-062]. Operator interactions — selection, Drive edits, manual overrides, move staging — shall remain possible regardless of ready-state. The team's per-turn clock and time budget continue to run per [01-REQ-037] and [01-REQ-038] independently of ready-state; expiry of the team's clock declares the turn over via [01-REQ-039] regardless of any operator's ready-state. *(Amended per 08-REVIEW-011 resolution.)*

**08-REQ-064**: The initial ready-state of every operator at the start of every turn shall be `not-ready`. *(Amended per 08-REVIEW-011 resolution.)*

**08-REQ-064a**: Coaches (per [05-REQ-067]) and admins acting via implicit-coach permission (per [05-REQ-066]) shall have **no ready-state** — they are read-only observers of the team's session per [08-REQ-052a] and [08-REQ-052b]. Their connections shall not be counted in the unanimity condition of [08-REQ-062], and their UI shall not expose a ready-state toggle. The presence display of [08-REQ-032] shall visually distinguish a coach/admin observer from a member operator. *(Added per 08-REVIEW-011 resolution.)*

---

### 8.13 Live Operator Interface — Drive Management

**08-REQ-052**: The move interface for a selected snake shall expose a control by which the current selector can add a Drive to that snake. Adding shall present a dropdown of registered Drive types ordered by the pinned-heuristics-then-lexicographic scheme: pinned heuristics (from the `pinnedHeuristics` array in `global_centaur_params`) appear first in pinned order; remaining heuristics are ordered lexicographically by `nickname`, with `heuristicId` as tiebreaker ([06-REQ-007]). *(Amended per 08-REVIEW-005 resolution: dropdownOrder replaced with pinned-heuristics + lexicographic fallback.)*

**08-REQ-052a**: The application shall provide a **coach mode** entry point into the live operator interface for any in-progress game involving a Centaur Team for which the authenticated user is a designated coach per [05-REQ-067] or for which the user holds implicit coach permission as an admin per [05-REQ-066]. Coach mode shall render the same live operator interface as a member of that team would see — the full board display, selection state, Drive portfolios, heuristic decompositions, action log, header, and Captain controls panel — but every mutating affordance (selection mutation, snake selection acquisition, Drive add/remove, portfolio weight adjustment, per-operator ready-state toggle, turn submission, team ready check (game start), and any Captain-only control) shall be disabled and visibly indicated as read-only. The coach connection to the team's filtered SpacetimeDB views shall be obtained via the coach SpacetimeDB token issuance path defined in [05] §3.4 and authorised per [05-REQ-067]. The coach mode entry point shall be reachable from the game's Live Spectating view (§8.16) and from the Team Profile (§8.18a) when an in-progress game is in flight.

**08-REQ-052b** *(negative)*: Coach mode shall not expose any affordance that would cause a write to Convex or to SpacetimeDB on behalf of the team being coached. Any UI control that would, in member mode, dispatch such a write shall be either hidden or rendered disabled in coach mode.

**08-REQ-052c**: Coach mode (08-REQ-052a) shall expose an **inspection** affordance with semantics identical to the replay-mode inspection affordance specified in the amended 08-REQ-074. Specifically: a coach client may at any time inspect any snake on the team being coached; the inspection is purely client-local; the inspection shall never write any Convex or SpacetimeDB state; the inspection shall never produce a selection shadow on the board; the inspection shall never displace or otherwise interact with any operator's selection; and each coach client may have at most one inspected snake at a time, held only in that client's local UI state. Coach inspection shall coexist with the live operator selection shadows produced by the team's connected operators per [08-REQ-039]: the coach simultaneously sees the team's operators' real selection shadows on the board and the coach's own client-local inspection state in their portfolio / stateMap / worst-case world / decision breakdown / per-direction candidate highlight panels. The coach's read scope is already established by [05-REQ-067] (and, for admin coaches, [05-REQ-066] / [05-REQ-067]); this requirement adds no new Convex mutation, no new SpacetimeDB write path, and no new authorisation rule. *(Resolved per 08-REVIEW-008.)*

**08-REQ-052d** *(negative)*: Coach inspection (08-REQ-052c) shall not be exposed through any affordance whose visual or interaction grammar could be confused with operator selection. In particular, the click-to-select gesture used by team members per [08-REQ-042] shall be replaced or visibly differentiated in coach mode (for example, by a distinct cursor, a distinct hover treatment, a distinct activation gesture such as click-with-modifier or right-click, and/or a distinct on-board indicator that is plainly not a selection shadow), so that a coach can never mistake an inspection action for a selection action and so that other observers cannot mistake the coach's inspection state for an operator's selection. *(Resolved per 08-REVIEW-008.)*

**08-REQ-053**: Selecting a Drive type from the dropdown shall activate the targeting mode appropriate to that Drive type's target type:
- **Snake targeting**: the board enters a mode in which only those snakes for which the Drive's target-eligibility predicate ([07-REQ-007]) returns true are highlighted as clickable; ineligible snakes are visually dimmed; clicking an eligible snake confirms it as the Drive's target.
- **Cell targeting**: the board enters a mode in which only those cells for which the Drive's target-eligibility predicate returns true are highlighted as clickable; ineligible cells are visually dimmed; clicking an eligible cell confirms it as the Drive's target.

**08-REQ-054**: In either targeting mode, pressing Tab shall cycle the highlighted candidate target through eligible targets in a fully deterministic order: primary sort by A*-distance from the selected snake's head, nearest first; secondary sort (for candidates at equal A*-distance) by clockwise angle in board coordinates from the selected snake's current head direction, starting at 0° (straight ahead) and increasing clockwise through 360°; tertiary sort (for candidates that remain tied after the first two keys) by target identity — for snake targets the snake id ascending, and for cell targets the cell coordinates in row-major order (row ascending, then column ascending). Pressing Escape shall cancel targeting without adding the Drive and shall not alter the snake's selection state. *(Resolved per 08-REVIEW-006.)*

**08-REQ-055**: Confirmation of a target shall cause the Drive to be added to the snake's portfolio at that Drive type's default weight via [06-REQ-015]. No additional operator confirmation beyond the target click shall be required.

**08-REQ-056**: Active Drives on the selected snake shall be listed in the snake's control panel, each showing the Drive type, the target, the current portfolio weight, an editable weight control, and a remove affordance. Weight edits and removals shall take effect immediately via [06-REQ-015]; the framework shall react per [07-REQ-015].

**08-REQ-057**: Drive assignments, weight overrides, activation overrides, and the per-snake temperature override shall persist across turns and across deselection, per [06-REQ-016]. The interface shall not reset any of these fields as a side effect of selection changes or turn transitions.

**08-REQ-058** *(negative)*: The application shall not provide an affordance to add Drives whose types are not registered in the team's heuristic default configuration ([06-REQ-005]). Drive type registration is a code-level concern of the Centaur Team's Snek Centaur Server library usage, not a runtime UI affordance.

---

### 8.14 Captain Controls

**08-REQ-065**: When the authenticated human is the Captain of the Centaur Team ([05-REQ-011]), the header of the live operator interface shall expose a single Captain control affordance: a **turn-submit** action that immediately declares the team's turn over ([01-REQ-039]) regardless of the per-operator ready-state (§8.12) of any other operator, submitting all currently-staged moves. *(Amended per 08-REVIEW-011 resolution.)*

**08-REQ-066**: The Captain's turn-submit affordance shall additionally be bindable to a keyboard shortcut so the Captain can operate it without pointer input. The specific key binding is a design-phase decision.

**08-REQ-067** *(negative)*: Operators who are not the Captain shall not see the Captain turn-submit affordance, and any attempt to invoke it — including via keyboard shortcut — shall be rejected by [06]'s function contract surface per [06-REQ-031] even if it reaches the mutation layer. The per-operator ready-state toggle of [08-REQ-061] is *not* a Captain-only affordance — every member operator owns their own ready-state regardless of role.

**08-REQ-068**: Per-operator ready-state toggles shall produce an `operator_ready_toggled` entry in the action log ([06-REQ-036]) per [06-REQ-040b]. Turn submissions issued by the Captain shall produce the team-side turn-submission event category of [06-REQ-036]. *(Amended per 08-REVIEW-011 resolution.)*

---

### 8.15 Unified Replay Viewer

**08-REQ-069**: The application shall provide a **unified Replay Viewer** for any game whose status is `finished` ([05-REQ-027]) and for which a persisted replay exists per [05-REQ-040]. The Replay Viewer shall combine two viewing modes into a single interface:
- **Board-level replay** (turn granularity): displays board state, snake positions, items, hazards, scoreboard, and turn events. Available for all games to all authenticated users.
- **Team-perspective replay** (sub-turn granularity): displays the full team experience including operator selections, Drive states, stateMaps, worst-case worlds, decision breakdowns, and staged-move attribution. Available only for games in which the viewer participated as a team member, scoped to that team's data.

**08-REQ-070**: The board-level replay mode shall source all displayed data from the persisted replay of [05-REQ-040] and shall never consult a SpacetimeDB game instance, consistent with [05-REQ-044]. The replay viewer shall therefore remain functional for replay viewing after the source game's SpacetimeDB instance has been torn down per [05-REQ-037].

**08-REQ-070a**: The board-level replay mode shall render board state at turn granularity: the cell layout, snake positions and bodies, items, hazards, fertile tiles, and per-team scoreboard shall be shown for the currently-selected turn. The rendering shall be visually consistent with the Live Spectating view (§8.16) such that familiarity with the live view carries over to the replay view. The board-level mode obtains its scrubbing affordance from the unified timeline control specified by [08-REQ-072] / [08-REQ-072a]–[08-REQ-072d].

**08-REQ-070b**: The board-level replay mode shall display a per-turn **event log** listing the turn events of the currently-selected turn as produced by turn resolution — at minimum death events (with cause), food-eaten events, potion-collection events, severing events, spawn events, and effect-application / effect-cancellation events. The set of event types shall match the closed enumeration defined by [01] and [04].

**08-REQ-071**: The team-perspective replay mode shall present the same UI components as the live operator interface (§§8.9–8.13), rendered in a read-only mode in which all mutating affordances — move staging, Drive add/remove/edit, manual-mode toggling, per-operator ready-state toggling, turn submission — are disabled, while all state-inspection affordances — snake **inspection** (the client-local non-mutating affordance per [08-REQ-074], not the operator-control selection mechanic of [06] which is unavailable in replay), direction preview, worst-case world preview, decision breakdown table — remain fully functional. The team-perspective mode obtains its scrubbing affordance from the unified timeline control specified by [08-REQ-072] / [08-REQ-072a]–[08-REQ-072d].

**08-REQ-071a**: The team-perspective replay mode shall be available exclusively for games in which the logged-in human participated as a team member.

**08-REQ-072**: The replay viewer shall expose a single **unified timeline control** that governs scrubbing for both the board-level and the team-perspective replay modes. The timeline control shall provide play, pause, a scrubber, a playback-speed control, and a **mode toggle** between Per-Turn mode and Timeline mode (per [08-REQ-072a]). The semantics of the scrubber, the speed-control set, the rendering of turn boundaries, and the keyboard navigation differ between the two modes per [08-REQ-072b], [08-REQ-072c], and [08-REQ-072d]. At any scrubber position `t` the viewer shall display the reconstructed game state at that position: the board-level mode renders the public board state, while the team-perspective mode additionally renders which snake each operator had selected at that moment, each snake's manual-mode flag, each snake's active Drives and their targets and weights, each snake's per-direction stateMap and worst-case world and annotations and heuristic outputs, the per-operator ready-state at that moment, the staged moves for each snake and the identity that staged them, and temperature overrides in effect. This reconstruction is the union of [05-REQ-040]'s persisted replay and [06-REQ-035]'s action log. *(Amended per 08-REVIEW-010 resolution: per-mode scrubbing semantics introduced; the prior single-set `{0.5×, 1×, 2×, 4×}` pin is superseded.)*

**08-REQ-072a**: The timeline control shall expose a **mode toggle** with two settings: **Per-Turn mode** and **Timeline mode**. The chosen mode and the chosen speed-within-mode shall be persisted in client-local UI state and restored on subsequent navigation within the same browser session; they shall not be persisted to Convex. The default mode on first entry to the replay viewer shall be Per-Turn mode. *(Added per 08-REVIEW-010 resolution.)*

**08-REQ-072b**: In **Per-Turn mode**, the scrubber shall display turns as equidistant tick marks (one tick per turn). Scrubbing shall snap to the **end of each turn** (the centaur-state state-of-the-world that operators saw at the moment they were declaring submissions); no intra-turn positions shall be addressable. Playback shall advance one turn per tick at the configured rate. The supported playback-speed set shall be **{0.25, 0.5, 1, 2, 4, 8} turns/second**. *(Added per 08-REVIEW-010 resolution.)*

**08-REQ-072c**: In **Timeline mode**, the scrubber's horizontal axis shall represent wall-clock time of the original game from game start (left) to game end (right). Turn boundaries shall be rendered along the timeline as **turn-marker glyphs** at the actual clock time at which each turn was declared over; spacing between markers shall reflect the variable real wall-clock duration of each turn under the chess-clock mechanism (markers shall not be equidistant). Scrubbing shall be continuous along clock time. Playback shall advance at a scalar multiple of real time. The supported playback-speed set shall be **{0.25×, 0.5×, 1×, 2×, 4×, 8×}**. The speed-control widget shall render the current mode's unit in its label (e.g., "2 turns/s" in Per-Turn mode and "2× speed" in Timeline mode). *(Added per 08-REVIEW-010 resolution.)*

**08-REQ-072d**: Keyboard navigation in the unified timeline control shall be as follows. In **Timeline mode**: `Left`/`Right` (no modifier) seek ±1 second of clock time; `Shift+Left`/`Shift+Right` seek ±200 ms; `Ctrl+Left`/`Ctrl+Right` (interpreted as `Cmd+Left`/`Cmd+Right` on macOS) snap to the previous/next turn-marker keyframe. In **Per-Turn mode**: `Left`/`Right` advance one turn backward/forward; modifier-key bindings in Per-Turn mode are deferred to Phase-2 design. *(Added per 08-REVIEW-010 resolution.)*

**08-REQ-073**: Historical operator selections shall be rendered during team-perspective replay as coloured shadows on the appropriate snakes using the same per-operator colours used in live play. An operator who was not connected at a given historical moment shall not produce a shadow for that moment.

**08-REQ-074**: The replay viewer shall permit the logged-in human to **inspect** a snake at the scrubbed timestamp. Inspection is a purely client-local affordance, distinct from the operator-control **selection** affordance owned by [06] ([06-REQ-018] through [06-REQ-024]): each viewer client may have at most one inspected snake at a time; inspection state is held only in the viewer's client-local UI state; inspection shall never write any Convex or SpacetimeDB state; inspection shall never produce a selection shadow on the board; and inspection shall never displace or otherwise interact with any operator's selection. Historical operator selection shadows reconstructed from the action log per [08-REQ-073] shall continue to be displayed alongside the inspecting client's local inspection state, unaffected by the viewer's choice of inspected snake. *(Resolved per 08-REVIEW-008.)*

**08-REQ-075**: The replay viewer shall permit **inspection** of any snake on the viewed team at any scrubbed moment regardless of which operator (if any) had that snake selected at that moment in the original game.

**08-REQ-075a** *(negative)*: The team-perspective replay shall not display, reconstruct, or expose any state belonging to opposing teams beyond what was visible through [04]'s RLS rules to the owning team at the original time of play. In particular, any opposing snake that was invisible to the owning team at a given historical moment shall remain invisible in replay at that moment.

**08-REQ-075b**: The board-level replay mode shall not reconstruct or display any data that depends on the Centaur-subsystem action log of [06]. In particular, the board-level mode shall not display which operator had selected which snake at any moment, nor any per-operator coloured shadows, nor any stateMap / worst-case-world / heuristic breakdown data.

**08-REQ-075c**: The replay viewer shall expose a **direct link** affordance that produces a URL identifying the specific game being viewed, such that another authenticated user opening the URL is taken directly to that game's replay viewer.

---

### 8.16 Live Spectating

**08-REQ-080**: The application shall provide a **Live Spectating** view for any game whose status is `playing` per [05-REQ-028]. The view shall be accessible to every authenticated user without requiring membership in any participating Centaur Team.

**08-REQ-081**: Entry to the Live Spectating view shall cause the UI to obtain a **spectator SpacetimeDB access token** for the target SpacetimeDB game instance, issued by Convex per [03-REQ-026], [05-REQ-035], and the spectator-token provisions of [03]. The UI shall present this token to the runtime when establishing its subscription connection per [04-REQ-018].

**08-REQ-082**: The Live Spectating view shall subscribe to the SpacetimeDB game instance's state using subscription patterns that satisfy [04-REQ-054]'s support for a current-state view with incremental updates. The UI shall render board state, snake states, items, hazards, fertile tiles, and turn events as delivered by the subscription, in real time.

**08-REQ-083**: The Live Spectating view's rendering shall honour the invisibility semantics of [04-REQ-047] without any client-side workaround: a snake whose `visible` field is `false` shall not be displayed to a spectator connection, consistent with the server-side filter. The UI shall not attempt to infer or reconstruct invisible-snake state from any channel.

**08-REQ-084**: The Live Spectating view shall display a **scoreboard** per participating team. The scoreboard shall be sourced exclusively from a dedicated SpacetimeDB scoreboard view that publishes per-team aggregate quantities (team score, alive-snake count, aggregate length) computed server-side over the true alive-snake set — including any contributions from snakes whose `visible` field is `false` per [04-REQ-047] — and that exposes only those aggregates to spectator subscriptions. The client shall render the aggregates exactly as delivered by the view and shall not attempt to compute or correct them from any other channel. The scoreboard shall update live in response to subscription deliveries. *(Amended per 08-REVIEW-018 resolution: scoreboard is a server-side aggregate view, not client-aggregated from per-snake data, so invisibility cannot leak through omitted contributions.)*

**08-REQ-084b** *(negative)*: The application shall not compute team-level aggregate quantities (team scores, total alive-snake length, alive-snake counts, win-condition state, or any analogous aggregate) by aggregating raw per-snake subscription data on the client. All such aggregates are delivered by purpose-built SpacetimeDB views that compute them server-side over the true game state, so that the visibility-filter posture of [04-REQ-047] is not undermined by client-side reconstruction. *(Added per 08-REVIEW-018 resolution.)*

**08-REQ-085**: The Live Spectating view shall display the current turn number and, per participating team, the team's current remaining chess-timer budget and whether the team has declared its turn over for the current turn, consistent with the per-team time-budget data supplied by [04]'s subscription interface.

**08-REQ-086** *(negative)*: The Live Spectating view shall not expose any affordance that stages moves, selects snakes, toggles per-operator ready-state, or otherwise mutates game-runtime or Centaur-runtime state. Spectator access tokens per [03-REQ-026] do not authorise any such mutation and the UI shall not attempt any.

**08-REQ-087**: The Live Spectating view shall provide a **timeline scrubber** that permits the spectator to navigate to any previously completed turn of the current game and view the reconstructed board, snake, item, scoreboard, and event-log state at that turn, using the historical query capability of [04-REQ-057]. On entry to the Live Spectating view, the UI shall subscribe to the game's full historical state up-front (per [04-REQ-054]'s mid-game-join subscription pattern), accepting bounded entry latency proportional to game length; games are bounded to at most a few hundred turns and the worst-case entry latency on long games is acceptable. Scrubbing backward shall not interrupt the incoming live subscription; returning to the live head shall resume live rendering. *(Amended per 08-REVIEW-019 resolution: up-front full-history subscription on entry, no lazy-fetch state machine.)*

**08-REQ-088**: While the spectator is scrubbed to a historical turn, the Live Spectating view shall visibly communicate to the user that the display is not live, and shall provide a one-action affordance to return to the live head.

**08-REQ-089**: The Live Spectating view shall release its subscription and discard its spectator access token when the user navigates away from the view or when the game transitions to `finished` per [05-REQ-028].

---

### 8.17 Data Source Abstraction

**08-REQ-076**: The application shall implement a data-source abstraction under which the UI components of §§8.9–8.13 read board state, turn number, staged moves, chess-timer state, and computed display state through a uniform interface that the live mode binds to the current game's SpacetimeDB subscription and the current team's Centaur state subscription ([06-REQ-043]), and that the replay mode binds to the persisted replay and action log read from Convex ([05-REQ-040], [06-REQ-035]). This data-source abstraction is exported by `@team-snek/centaur-lib` and serves as the primary stable interface between the library and the operator web application, regardless of how teams modify the UI in their fork of the reference implementation repository ([02-REQ-032a]).

**08-REQ-077**: A UI component of the live operator interface shall not be required to distinguish whether it is rendering live or replayed state. Read-only enforcement in replay mode shall be accomplished by the data-source abstraction refusing mutation operations, not by each UI component implementing a read-only branch of its own.

**08-REQ-078** *(negative)*: The data-source abstraction shall not expose a mutation surface at all in replay mode. Attempts to invoke a mutation through a replay-mode data source shall fail without side effect.

---

### 8.17a Source Ownership and Customisation

**08-REQ-079**: The application shall be delivered in the Snek Centaur Server reference implementation repository ([02-REQ-032a]), not as part of the Centaur Server library itself. Teams obtain the application by forking the reference repository and customise it by modifying their fork directly — full source ownership, not a bounded extension point. Teams may modify, replace, or extend any Svelte component, add pages, change layouts, or restructure the UI as they see fit. No customisation shall relax any of the invariants stated in this module or in [06]; correctness is enforced externally by Convex function contracts ([06]) and security enforcement points ([02-REQ-033]).

**08-REQ-080a** *(negative)*: No customisation of the application shall be relied upon for any security or correctness invariant, per [02-REQ-033]. All invariants that constrain Centaur-state mutations shall remain enforced by [06]'s function contract surface regardless of what a team's forked application chooses to present or hide.

---

### 8.18 Player Profile

**08-REQ-090**: The application shall provide a **Player Profile** view for every user record per [05-REQ-004]. Each authenticated user shall have direct access to their own Player Profile via the global navigation of [08-REQ-010]. Access to other users' profiles shall be permitted at minimum via links from team member listings and game history. All Player Profile views are accessible only to authenticated users per [08-REQ-006]; there is no unauthenticated/public profile surface. *(Amended per 08-REVIEW-016 resolution.)*

**08-REQ-091**: The Player Profile view shall display at minimum the user's OAuth-provided display name, current and historical Centaur Team memberships, and a chronological **game history** listing every game in which the user was either a member of a participating team at the time (per the game's participating-team snapshot of [05-REQ-029]) or is a current member of one of those teams, together with each game's room, date, the participating teams, the final result (win/loss/draw), and the final scores per [05-REQ-038]. The Player Profile shall not display the user's email address to any viewer, including the user themselves on their own profile (the email is owned by the OAuth provider and any change must be made there). *(Amended per 08-REVIEW-016 resolution: email removed from displayed identity.)*

**08-REQ-091a** *(negative)*: No application view shall expose any user's email address to any other user, nor to the user themselves. Email addresses are stored in Convex solely for OAuth identity matching and admin operations and shall not be returned by any user-scoped Convex query (player profile, team-member listing, team management, game-history attribution, leaderboard, or any other user-facing surface). *(Added per 08-REVIEW-016 resolution. Downstream impact: [05]'s query layer must enforce this — no [05] user-scoped query may include the email field in its returned shape.)*

**08-REQ-092**: The Player Profile view shall display aggregate statistics derived from the user's game history: at minimum, games played, win rate, and average team score. These statistics shall be computed from the same data that populates the game history listing and shall therefore be consistent with it.

**08-REQ-093**: The Player Profile view shall resolve historical team attributions using the participating-team snapshot of [05-REQ-029] rather than the current team record, so that a historical game continues to show the team the user was playing for at the time even if the user has since changed teams or the team has been archived per [05-REQ-015a]. *(Amended per 08-REVIEW-017 resolution: archive-only semantics for Centaur Teams.)*

---

### 8.18a Team Profile

**08-REQ-094**: The application shall provide a **Team Profile** view for every Centaur Team per [05-REQ-008]. The Team Profile shall be accessible to every authenticated user; access is gated by the platform-wide authentication requirement of [08-REQ-006] and there is no unauthenticated/public team profile surface. *(Amended per 08-REVIEW-016 resolution.)*

**08-REQ-095**: The Team Profile view shall display at minimum the team's name, display colour, current Captain, current members per [05-REQ-011], the team's nominated server domain and its latest health status per [05-REQ-009], and a chronological game history listing every game in which the team participated, with each game's room, date, opposing teams, final result, and final scores. The game history shall include all games in which the team participated, visible to any authenticated user.

**08-REQ-096**: The Team Profile view shall display aggregate statistics derived from the team's game history: at minimum, games played, win rate, average score, and head-to-head records against each other team the team has ever played against.

**08-REQ-097**: The Team Profile view shall resolve historical opponent attributions using the participating-team snapshots of [05-REQ-029] so that head-to-head records remain stable even if an opposing team has since been archived per [05-REQ-015a]. *(Amended per 08-REVIEW-017 resolution: archive-only semantics for Centaur Teams.)*

**08-REQ-098** *(negative)*: The Team Profile view shall not expose any mutating affordance over team state. Mutation of team state is the exclusive responsibility of the Team Management view (§8.5b), which enforces the Captain-only scope of [08-REQ-023d] and the mid-game freeze of [08-REQ-023e].

---

### 8.19 Leaderboard

**08-REQ-094a**: The application shall provide a global **Leaderboard** view that ranks Centaur Teams by one of a closed set of criteria. The closed set shall be at minimum: win rate (with a minimum games-played qualifying threshold), total wins, and average score.

**08-REQ-094b**: The Leaderboard view shall permit the user to switch between the criteria of [08-REQ-094a] and to filter results by time window from a closed set including at minimum: all time, last 30 days, and last 7 days.

**08-REQ-094c**: The Leaderboard view shall permit optional restriction of the ranking to games played within a specific room. When a room restriction is applied, the ranking shall consider only games whose room matches.

**08-REQ-094d**: The Leaderboard view shall link each ranked team directly to that team's Team Profile view per §8.18a.

**08-REQ-094e**: The Leaderboard view shall resolve historical attributions using the participating-team snapshots of [05-REQ-029], so that a team's ranking continues to reflect games it played under its historical identity even if the team has since been archived per [05-REQ-015a]. Archived teams shall continue to appear in the default leaderboard view under their archived identity, consistent with the archive-only semantics of [05-REQ-015a] (which is a live-state hide-from-listings action and not a historical-state rewrite, paralleling [05-REQ-021a] for room archiving). *(Amended per 08-REVIEW-017 resolution: deletion is not a thing in this platform; archived teams remain in leaderboards by default.)*

**08-REQ-094f** *(negative)*: The Leaderboard view shall not be accessible in a way that exposes team or player data to unauthenticated visitors. Leaderboard access is subject to the authentication requirement of [08-REQ-006]. *(Amended per 08-REVIEW-016 resolution: deferral removed; authentication requirement is positively pinned.)*

---

### 8.20 API Key Management

**08-REQ-095a**: The application shall provide an **API Key Management** view accessible to every authenticated user, through which the user may create new API keys per [05-REQ-051] and revoke API keys they previously created per [05-REQ-052]. The view shall list the user's active and revoked API keys with at minimum each key's human-chosen label, creation timestamp, and revocation timestamp where applicable.

**08-REQ-095b**: When an API key is created via the API Key Management view, the UI shall display the key's plaintext exactly once, at the moment of creation, consistent with [05-REQ-046] and [03-REQ-034]. After that single display, the UI shall never present the plaintext again. The UI shall provide an explicit affordance for the user to copy the plaintext to their clipboard before dismissing the creation dialog.

**08-REQ-095c** *(negative)*: The API Key Management view shall never display, store, or transmit API key plaintext except during the single creation-time disclosure of [08-REQ-095b]. Subsequent views of the key shall show only its label and metadata per [08-REQ-095a].

**08-REQ-095d**: The API Key Management view shall visibly communicate to the user that an API key's authorization scope is bounded by the user's own current authorization scope per [05-REQ-047], so that the user understands that losing team roles or membership will correspondingly reduce what actions their API keys can perform (subject to 05-REVIEW-004).

---

### 8.21 Admin Experience

**08-REQ-096a**: When the authenticated user holds the platform admin role ([05-REQ-065]), the application shall expose the following additional capabilities:

- **Team visibility**: The admin shall be able to view all Centaur Teams, their members, roles, and nominated server domains, regardless of membership ([05-REQ-066]).
- **Game visibility**: The admin shall be able to view all games (active and completed), including those in rooms or involving teams the admin is not a member of ([05-REQ-066]).
- **Replay access**: The admin shall be able to view the team-perspective replay (sub-turn within-turn actions) for any team in any game, regardless of team membership ([05-REQ-066]). For finished games this access is shared with all authenticated users; the admin distinction is meaningful for live-game cross-team visibility, where the admin holds implicit coach permission for every team per [05-REQ-067].
- **Live coach access**: The admin shall be able to enter the live operator interface of any in-progress game in any team's read-only coach mode ([08-REQ-052a]) without being explicitly designated as a coach of that team.

**08-REQ-096b** *(negative)*: The admin experience shall be read-only with respect to game state and Centaur-subsystem state. Admin users shall not be able to stage moves, edit Drive portfolios, toggle per-operator ready-state, or otherwise act as operators for teams they do not belong to. Admin visibility is observational, not operational.

---

### 8.22 Lifecycle and Session Boundaries

**08-REQ-081a**: The application's live operator interface shall become available on the team's navigation for a given game at the moment that game transitions to `playing` ([05-REQ-028]) and shall remain available until that game transitions to `finished`.

**08-REQ-082a**: On a game transitioning to `finished`, the live operator interface shall be replaced for connected operators by a terminal state indicator that surfaces the final scores ([05-REQ-038]) and a link to open the same game in the replay viewer. The terminal state shall not offer any mutating affordances.

**08-REQ-083a**: When the application loses its subscription to either SpacetimeDB or Convex, it shall surface the loss to the operator and shall not fabricate missing state from stale caches. On recovery, the application shall resubscribe and resume rendering from fresh state.

**08-REQ-084a** *(negative)*: The application shall not persist any authoritative state of its own across sessions. All operator-visible state is derived from [04], [05], or [06] on each session, consistent with [07-REQ-057]'s posture for the framework.

---

### 8.23 Cross-Cutting UI Invariants

**08-REQ-100**: The application shall surface Convex-side invariant rejections to the user as explicit, user-legible feedback at the point of the rejected action. The UI shall not silently swallow rejection errors.

**08-REQ-101**: The application shall treat any affordance whose authoritative enablement is governed by a Convex-side invariant (for example, mid-game roster freeze, minimum team count, ready-check gate) as an affordance whose *enabled* state in the UI must be derivable from Convex-held state, not from client-held optimism. Where this derivation is not yet possible because the invariant lives only in Convex mutation handlers, the UI shall still dispatch the mutation and surface the result per [08-REQ-100].

**08-REQ-102**: The application shall honour the distinction between the immutable parameter snapshot bound to a game ([05-REQ-024]) and the current parameter defaults held on a room. In particular, viewing a game's configuration — whether the game is `playing`, `finished`, or referenced from replay or history — shall show the game's snapshotted parameters, not the room's current defaults, even if the two differ.

**08-REQ-103**: The application shall be resilient to a Centaur Team being archived per [05-REQ-015a]: views that reference historical teams (game histories, leaderboards, profiles) shall continue to render using the participating-team snapshot, and views that reference a currently-live team that has been archived shall present the archived state to the user explicitly rather than failing or showing broken references. *(Amended per 08-REVIEW-017 resolution: archive-only semantics for Centaur Teams.)*

**08-REQ-104**: Every mutating action taken by the application shall be dispatched against the platform Convex runtime of [05] and shall be subject to the same invariants as the equivalent HTTP API call, including the mid-game roster freeze of [05-REQ-013]. The UI shall not attempt to bypass or work around any Convex-side invariant; where an action is disallowed by Convex, the UI shall surface the rejection to the user.

---

## Design

### 2.1 Application Topology, Tech Stack, and Repository Layout

The application is a SvelteKit project running under the Node.js adapter inside the Snek Centaur Server's single Node process, co-resident with the bot framework runtime ([07] §2.1). Co-residency is required because the `/.well-known/snek-game-invite` endpoint (08-REQ-005) hands the received per-Centaur-Team game credential directly to the in-process bot framework session manager (08-REQ-003, 08-REQ-005); a separate process boundary would require an out-of-band channel that the architecture explicitly avoids. *(See [02] §2.16a; consistent with 02-REQ-030 / 02-REQ-032a.)*

**Stack**:
- **Framework**: Svelte 5 + SvelteKit (Node adapter).
- **Component library**: shadcn-svelte (used for primitives only; all interaction logic lives in application components, keeping the surface forks may safely replace minimal).
- **Convex client**: `convex-svelte` for reactive queries and mutations against [05]'s and [06]'s function contract surfaces.
- **SpacetimeDB client**: the SpacetimeDB browser TypeScript client (08-REQ-003), used for live game subscriptions and live spectating.
- **Presence**: `@convex-dev/presence` for operator presence and per-operator ready-state visibility (08-REQ-035, 08-REVIEW-004).
- **Heuristic registry**: build-time import of `HEURISTIC_REGISTRY` from `@team-snek/heuristics` ([07] §2.3, [02] §2.16a), satisfying 08-REVIEW-021's drift-elimination property at the build-artifact level.
- **Library dependency**: a published library package providing the data-source abstraction and other library APIs (§2.4 below). This module's source canonicalises the package name to `@snek-centaur/server-lib` consistent with [02] §2.13 / §2.16a; 08-REQ-076 names the same artifact `@team-snek/centaur-lib` and a new REVIEW item (08-REVIEW-022) is filed to flag the inconsistency for the human resolution path. The two names refer to one and the same artifact; nothing in this design depends on which name wins.

**Repository topology**: the application is delivered as a separate forkable reference implementation repository per 02-REQ-032a / 08-REQ-079, **not** a workspace package within the platform monorepo. Teams obtain it by forking; their fork installs `@snek-centaur/server-lib`, `@snek-centaur/engine`, and `@team-snek/heuristics` from the published registry. The reference repository's directory layout follows SvelteKit conventions:

```
src/
  app.html
  app.d.ts
  hooks.server.ts                      # Convex Auth session hooks
  routes/                              # see §2.2 routing topology
  lib/
    server/                            # server-only modules (invitation endpoint, healthcheck)
      invitation.ts                    # /.well-known/snek-game-invite handler (§2.6)
      bot-session-manager.ts           # in-process handoff to @snek-centaur/server-lib
    components/                        # board renderer, header, decision table, etc.
    data-source/                       # consumers of @snek-centaur/server-lib's data-source API
    presence/                          # @convex-dev/presence integration (§2.5)
    colour/                            # per-operator stable-colour function (§3.3)
static/
  .well-known/                         # served as static assets if not generated at request time
```

Forks are expected to modify this layout freely (08-REQ-079, 08-REQ-080a). The load-bearing contract teams must not break is the data-source abstraction surface (§2.4 / §3.2) and the invitation endpoint contract (§2.6 / §3.1).

---

### 2.2 Routing and Layout Hierarchy

The route topology partitions surfaces by which authority gates them (08-REQ-002, 08-REQ-006, 08-REQ-009c, 08-REQ-010, 08-REQ-013):

```
/                                       # home view (§8.3a) — auth required
/sign-in                                # sign-in page (08-REQ-002)
/sign-out                               # sign-out endpoint (08-REQ-009b)

/leaderboard                            # global leaderboard (§8.19) — auth required (08-REQ-094f)
/teams                                  # teams browser (§8.5a) — auth required
/teams/[teamId]                         # team profile (§8.18a) — auth required
/teams/[teamId]/manage                  # team management (§8.5b) — member-gated, Captain affordances inside
/teams/[teamId]/heuristic-config        # heuristic config (§8.4) — member-gated; Captain edits, others read-only
/teams/[teamId]/bot-params              # bot parameters (§8.5) — member-gated; Captain edits, others read-only
/teams/[teamId]/games                   # game history for the team (§8.7) — member of team or platform admin
/teams/[teamId]/live                    # live operator interface for the team's current playing game (§§8.9–8.14)

/rooms                                  # room browser (§8.6) — auth required
/rooms/[roomId]                         # room lobby (§8.8) — auth required; affordances scoped per role

/games/[gameId]/spectate                # live spectating view (§8.16) — auth required
/games/[gameId]/replay                  # unified replay viewer (§8.15) — auth required
/games/[gameId]/coach/[teamId]          # coach mode for a designated team (§8.16/§2.16) — coach or admin

/users/[userId]                         # player profile (§8.18) — auth required

/api-keys                               # API key management (§8.20) — auth required, scoped to caller

/admin                                  # admin landing (§8.21) — admin-only
```

**Layout hierarchy**: a single root layout enforces authentication via a `+layout.server.ts` load function that resolves the OAuth session against Convex and exposes the `user` record (08-REQ-007, 08-REQ-006); on absence it redirects unauthenticated callers to `/sign-in` for every non-exempt route (the exempt set is `/sign-in`, `/sign-out`, and the static asset surface; per 08-REVIEW-016 there is no public surface beyond the sign-in page). `/teams/[teamId]/...` is wrapped in a team-scoped layout that resolves the `team` record (and the caller's role on it: Captain | member | coach | admin | none) from Convex; child pages render gated affordances by branching on this role rather than by re-querying. `/games/[gameId]/...` is wrapped in a game-scoped layout that resolves the `game` record and its `participatingTeams` snapshot from Convex.

**Cross-server reachability**. The application is served by *one* Snek Centaur Server, which hosts a known set of Centaur Teams (08-REQ-004). The team-scoped routes whose semantics require this server's bot-framework process — heuristic config, bot params, the live operator interface, the team game history — are accessible only when `[teamId]` is one of this server's hosted teams (08-REQ-012, 08-REQ-028); navigating to such a route for a non-hosted team is refused by the team-scoped layout's load function with an explanatory empty state, consistent with 08-REQ-012. All other team-scoped routes (team profile, team management view, coach mode) are cross-server: any Snek Centaur Server's frontend renders them for any team. Cross-server deep-links are produced in the home view's "live games" section (08-REQ-010a) and in the team profile's "in-progress" indicators by resolving the team's `nominatedServerDomain` ([05-REQ-014]) and emitting an absolute URL to that server's `/teams/[teamId]/live` route. The receiving server handles auth on its own (the user is authenticated against Convex globally).

**Refusal semantics for `/teams/[teamId]/live`** (08-REQ-012): the load function checks `game.status === "playing"` for the team's current game; if no `playing` game exists it returns an empty-state component that explains "no game in progress" and links back to the team's home. This is a positive component, not an HTTP 404, so the navigation surface remains coherent.

---

### 2.3 Authentication and Session Management

**OAuth and user record**. Sign-in flows through Convex Auth's Google OAuth provider per [03] §3.14. The SvelteKit `hooks.server.ts` adapts Convex Auth's session cookie into a server-side session that exposes the user record per [05]'s `User` exported interface to every load function (08-REQ-006, 08-REQ-007). The user record carries the human's display name and the platform-admin flag; per 08-REQ-091a / 08-REVIEW-016 it does **not** include the email field on any client-visible projection.

**Captain status reactivity**. Captain status is read from `centaur_teams.captainUserId` ([05]) via a Convex reactive query subscribed by the team-scoped layout. When the Captain reactively changes mid-session — e.g., a Captain transfer from the Team Management view (08-REQ-023d), or the user being removed from the team — every gated affordance re-renders without page reload (08-REQ-008). Implementation pattern: a Svelte 5 `$derived` rune over the layout's reactive `team` value yields a `role: "captain" | "member" | "coach" | "admin" | "none"` value that descendant components read; affordances bind their `disabled`/visibility to this `$derived` value rather than to a load-time snapshot.

**Admin role**. The platform admin role per [05-REQ-065] is exposed on the user record as a boolean. Admin-only affordances (§8.21) bind to it through the same `$derived` reactivity (08-REQ-009c) so an admin role granted or revoked during the session takes effect immediately.

**Sign-out**. The `/sign-out` endpoint clears Convex Auth's session cookie and any client-held SpacetimeDB access tokens (08-REQ-009b), then redirects to `/sign-in`. SpacetimeDB sockets opened during the session are closed by the live-mode data source teardown (§2.4).

**Token issuance and storage discipline** (08-REQ-009 / 009a). The application never mints a SpacetimeDB access token of its own: every token is obtained through the Convex-mediated issuance path of [05-REQ-035] / [03] §3.17 by calling Convex actions and receiving the JWT in the response payload. Tokens are held in component-local memory only for the lifetime of the subscription that uses them — never persisted to localStorage, sessionStorage, IndexedDB, or cookies, and never reflected back into the URL or any UI surface. API key plaintext is shown exactly once at creation time (08-REQ-095b) via a modal that holds the plaintext in a closure with no logging side effect; dismissing the modal discards the plaintext.

---

### 2.4 Data-Source Abstraction (Centaur-Lib API)

The data-source abstraction (08-REQ-076 / 077 / 078) is the load-bearing contract between `@snek-centaur/server-lib` and the forked operator UI. Its design choice is the single most consequential one in this module because it determines what teams' forks may safely modify and what they must accept as fixed.

**Shape**. The abstraction is an interface (TypeScript type plus factory functions) the library exports; UI components consume it through Svelte 5 context injection rather than as a global rune store. Three factories produce three concrete bindings of the same interface:

- `createLiveDataSource({ gameId, centaurTeamId, gameCredential })` — binds reads to the SpacetimeDB game subscription and the Convex Centaur-state subscription ([06-REQ-043]); binds mutations through Convex's `[06]` function contract surface ([06-REQ-030]) and through SpacetimeDB's `stage_move` reducer ([04] §2.4).
- `createReplayDataSource({ gameId })` — binds reads to the persisted replay ([05-REQ-040]) and the action log ([06-REQ-035]); the mutation surface is **absent** (not present at the type level — replay-mode UI cannot accidentally call a mutation because no mutation function exists on the returned object). This satisfies 08-REQ-078's negative requirement structurally rather than at runtime.
- `createCoachDataSource({ gameId, centaurTeamId, coachToken })` — binds reads to the coached team's filtered SpacetimeDB views via the coach SpacetimeDB token issued per [05] §3.4 ([05-REQ-067]) and to the same Convex Centaur-state subscription a member would see; the mutation surface is **absent**, so coach-mode UI cannot mutate (08-REQ-052b).

The interface is structured as a set of *read* signals — Svelte 5 readable runes (specifically `$state` snapshots or `$derived` projections produced inside the factory) wrapping reactive subscriptions — and a *mutations* object whose presence depends on the binding (`live` only). UI components depend on the interface, not on which binding produced it (08-REQ-077): a single `<BoardDisplay>` component renders identically in live, replay, and coach mode by reading from `dataSource.boardState`, `dataSource.snakes`, `dataSource.selections`, etc.; whether those signals are sourced from a live SpacetimeDB subscription or from a reconstructed historical slice is invisible to the component.

**Why context injection rather than a global store**. Two replay viewers may be open in two browser tabs viewing different games simultaneously, and a single tab may host both a coach-mode panel and a replay panel. A global store would force a singleton binding that conflicts with this; per-component-tree context injection lets each panel host its own data source. Live-mode bindings are per-tab in practice (the application surfaces only one live game at a time per team), but the same context-injection pattern keeps the call shape uniform.

**Inspection state**. Inspection state (08-REQ-052c, 08-REQ-074) is **not** part of the data-source abstraction, because it is purely client-local UI state with no Convex or SpacetimeDB write path (08-REVIEW-008). Each panel's `<InspectionProvider>` Svelte context owns a `inspectedSnakeId: SnakeId | null` rune; the data-source abstraction is unaware of inspection. This keeps the abstraction's contract identical between member, coach, and replay use sites — only the inspection provider varies.

**Mutation routing**. Live-mode mutations are dispatched as Convex mutations against [06]'s function contract surface (08-REQ-104), which is the ultimate authority for invariants (08-REQ-080a). The data source surfaces the mutation result (success or rejection) to the caller; UI components use this result to drive the user-feedback path of §2.18 (08-REQ-100). Move staging is dispatched directly to SpacetimeDB's `stage_move` reducer through the SpacetimeDB client, since [04] is the authoritative source for staged-move state.

**Replay-mode reconstruction**. The replay binding's read signals are `$derived` projections over a scrubbed-position cursor (`scrubberPositionRune: number`) of two underlying datasets: the persisted board-level replay ([05-REQ-040]) and, for team-perspective replay (08-REQ-071), the action log ([06-REQ-035]) for the viewer's team. Per-Turn-mode and Timeline-mode scrubbing both feed the same cursor; the cursor's units differ (turn index vs ms since game start) but the projection logic is identical. The action-log reconstruction yields, at any cursor position, the per-snake portfolio state, per-operator ready-state, per-snake selection state, and the per-snake `SnakeBotStateSnapshot` ([07] §3.4) that was current at the most recent prior write of each — i.e., it is a "scrubbed view of last-written state" rather than a continuous interpolation. This matches the replay reconstruction obligation of 08-REQ-072 and uses the action-log event union of [06-REQ-036] as the reconstruction substrate.

---

### 2.5 State Management and Cross-Cutting Reactivity

**Svelte 5 runes posture**. All UI reactivity uses Svelte 5 runes (`$state`, `$derived`, `$effect`). Reactive Convex queries are wrapped by `convex-svelte`'s `useQuery` analogue, which exposes a rune; reactive SpacetimeDB subscriptions are wrapped by a thin adapter that exposes a `$state`-backed rune updated by the SpacetimeDB client's table-row delta callbacks. This places every reactive input on the same uniform rune substrate so `$derived` compositions span Convex, SpacetimeDB, and presence sources without special-casing.

**Convex reactive query integration**. Each load function in the team-scoped, game-scoped, and platform-scoped layouts opens the Convex queries it needs and threads them down via context (the data source for game-scoped state; named layout context entries for cross-cutting state such as `currentUser`, `team`, `role`, `participatingTeams`). Mutations dispatch through `convex-svelte`'s mutation API and return a `Promise<Result>` whose rejection branch feeds §2.18's user-feedback path.

**SpacetimeDB subscription integration**. The live-mode data source opens one SpacetimeDB connection per (team, game) via the SpacetimeDB browser client, authenticated with the per-Centaur-Team game credential issued per [05] §3.4 / [03] §3.17. The connection subscribes to the queries described by [04] §2.12 for a member operator. The spectating data source opens a second SpacetimeDB connection authenticated with a spectator access token (08-REQ-081); subscriptions follow [04] §2.12's spectator pattern. Coach mode opens a third connection via the coach SpacetimeDB token path of [05] §3.4. Each connection is owned by its respective data source and torn down on data-source disposal (08-REQ-089, 08-REQ-082a, 08-REQ-083a).

**Network latency measurement** (08-REQ-036). The latency indicator measures end-to-end round-trip time against the SpacetimeDB subscription channel by issuing periodic lightweight heartbeat reads (subscribing to a singleton row whose updates are timestamped server-side) and computing `now() - lastUpdateTimestamp` debounced to the most recent N samples. This avoids requiring a new RTT-specific reducer or Convex field. The exact sampling interval (a few seconds) is a design discretion not visible in any contract.

**Presence integration via `@convex-dev/presence`** (08-REQ-035, 08-REVIEW-004). Each team's live session installs an `@convex-dev/presence` channel keyed `team:${centaurTeamId}:game:${gameId}` and joined by every connected operator (member, coach, admin) on entry to the live operator interface or coach view. The per-presence-record shape (extending `@convex-dev/presence`'s base shape) is:

```typescript
interface OperatorPresenceRecord {
  userId: string                 // resolves to a User record per [05]
  role: "member" | "coach" | "admin"
  displayName: string            // OAuth display name; never email
  colour: string                 // hex; per-operator stable colour for the game's lifetime (§3.3)
  currentSelectionSnakeId: string | null   // mirrors [06]'s snake_operator_state for header presence
  // Per-operator ready-state is read from [06] §2.1.5 / 06-REQ-040b directly,
  // not duplicated into presence — the presence record only proves connectedness.
}
```

Presence delivers connectedness; ready-state is read from [06]'s `operator_ready_state` table per [06-REQ-040b] (08-REQ-061). The header presence display (08-REQ-032) joins these two sources reactively: a `$derived` rune over both produces the per-operator presentation showing each connected operator's display name, colour, and current ready-state. The `role` field is what enables the visual distinction of coach/admin from member operators (08-REQ-064a).

**Per-operator stable-colour assignment**. The colour is assigned deterministically from `(gameId, userId)` so the same operator gets the same colour across reloads of the same game and across all clients viewing that game (08-REQ-035, 08-REQ-039, 08-REQ-073). The function takes both inputs and returns a hex colour from a fixed accessibility-screened palette of 16 hues, hashed to balance distribution. Specified as the exported `assignOperatorColour(gameId, userId)` in §3.3.

---

### 2.6 Game Invitation Endpoint

**Route**. SvelteKit `+server.ts` at `src/routes/.well-known/snek-game-invite/+server.ts` exposes a `POST` handler (08-REQ-005). The path is required to be exactly `/.well-known/snek-game-invite` because [05] §3.4 invitation orchestration calls this URL on the team's `nominatedServerDomain`.

**Request validation**. The handler validates the inbound JSON payload against [03]'s game-credential format (the per-Centaur-Team game credential JWT issued by Convex Auth's customJwt provider per [03] §3.15 and the invitation envelope per [03] §3.16). Validation steps:
1. Verify the envelope's signature against Convex's published JWT verification key per [03] §3.17.
2. Parse the `centaurTeamId` and `gameId` claims.
3. Verify the `centaurTeamId` is one of the teams hosted by this Snek Centaur Server (matched against a server-config-time list of hosted team IDs). Unknown teams return HTTP 403.
4. Verify the invitation has not already been accepted for this `(centaurTeamId, gameId)` pair (idempotence guard against duplicate Convex deliveries).

**Optional whitelist**. Server operators may configure an additional allowlist of acceptable inviting Convex deployment fingerprints (defence-in-depth in case Convex's signing key is misconfigured); this is a server-config concern, not a requirement, and absent the allowlist any signature-valid invitation from the platform's Convex deployment is accepted.

**Acceptance and handoff**. On successful validation the handler:
1. Persists the `(centaurTeamId, gameId, gameCredential, expiresAt)` record to a server-local store (in-memory, cleared on game end). Persistence is required so subsequent SvelteKit requests from this team's operators can read the credential.
2. Calls into the in-process `@snek-centaur/server-lib` bot-framework session manager via `startGameSession({ centaurTeamId, gameId, gameCredential, registry: HEURISTIC_REGISTRY, ... })` per [07] §3.3 to boot the team's bot-framework session. The session manager is co-resident in this Node process, so the call is a direct function invocation; no IPC.
3. Returns HTTP 200 with the response body shape defined in §3.1.

**Failure modes**. Invalid signature → 401. Unknown team → 403. Duplicate invitation for an already-accepted game → 200 with `alreadyAccepted: true`. Bot-framework boot failure → 500 with a diagnostic body. The endpoint never reveals server-internal state in error messages beyond the failure category.

---

### 2.7 Live Operator Interface — Board Renderer and Gestures

**Renderer choice**. The board is rendered with **SVG** as the primary substrate, with a single underlying HTML5 `<canvas>` layer used only for grid lines and base terrain rendering when the cell count exceeds a threshold. Rationale: SVG yields per-cell DOM nodes that bind cleanly to Svelte's reactivity and to per-cell event handlers (click-to-select 08-REQ-042, click-to-target 08-REQ-053, hover affordances), and the typical board size (≤ a few hundred cells) is well within SVG performance limits. The canvas fallback for large boards keeps the rendering complexity bounded without changing the gesture layer (gestures hit-test against an invisible SVG overlay regardless of which substrate paints the base layer). A pure-canvas approach was considered and rejected because hit-testing for click-to-select would require manual pick-region maintenance and would lose the accessibility tree.

**Layered rendering** (08-REQ-037 through 08-REQ-041, 08-REQ-048 through 08-REQ-051):
- **Layer 0 — terrain**: grid lines, hazard cells, fertile tiles. Static within a turn; re-renders only on board mutations.
- **Layer 1 — items**: food, invulnerability potions, invisibility potions. Re-renders on subscription deliveries.
- **Layer 2 — snakes**: alive snakes by team colour, head letter designation, neck-segment length label, effect outlines (invulnerability blue / negative-invulnerability red per 08-REQ-038), invisibility shimmer (own team only per 08-REQ-038's RLS posture). Re-renders on subscription deliveries.
- **Layer 3 — selection shadows**: per-operator coloured glows on selected snakes (08-REQ-039), driven by [06]'s selection record subscription joined to the per-operator stable-colour function (§3.3).
- **Layer 4 — staged-move markers**: distinctive border on the destination cell of each owned snake's staged move (08-REQ-041). Updates reactively as staged moves change in [04].
- **Layer 5 — candidate highlights**: per-direction stateMap-coloured overlay on the four cells adjacent to the currently-selected owned snake's head (08-REQ-040). Coloured by stateMap score on a monotone ramp; "no entry yet" cells render in a distinct neutral state (08-REQ-040, [07-REQ-049]).
- **Layer 6 — worst-case overlay**: when a direction is selected on an owned snake, this layer renders the worst-case simulated world for that (snake, direction) pair as translucent overlays (08-REQ-048). The annotations rendering called for by 08-REQ-049 is **deferred** in this design pass — [07] §3.4 (per the 07-REVIEW-014 cascade) excised the `WorldAnnotations` field from `SnakeBotStateSnapshot.worstCaseWorlds`, so the data substrate 08-REQ-049 names is not currently published by the framework. New REVIEW item 08-REVIEW-023 is filed to govern the annotations replacement design; until that REVIEW item is resolved this layer renders the simulated `state` only and surfaces no per-direction annotations. Hidden when no direction is selected (08-REQ-051).
- **Layer 7 — inspection overlays**: client-local inspection state (replay viewer 08-REQ-074 / coach mode 08-REQ-052c) drives the worst-case-world / candidate-highlight / decision-table panels for the inspected snake **without** producing any layer-3 selection shadow (08-REQ-052c, 08-REQ-074). In coach mode the inspected snake is decorated with a visually distinct indicator (e.g., a dashed magenta ring) explicitly differentiated from selection shadows (08-REQ-052d).

**Click-to-select gesture** (08-REQ-042). Click on a snake body cell whose snake the caller is eligible to select per [06-REQ-024] dispatches `selectSnake` to [06]. If the snake is currently selected by another operator, the gesture instead opens a displacement-confirmation modal; on explicit confirmation the modal dispatches `selectSnake` with the displacement flag set per [06-REQ-022]. Without confirmation no mutation issues. Pressing `Escape` while a snake is selected dispatches `deselectSnake`. Selecting a different eligible snake dispatches `selectSnake` for the new target (which implicitly releases the prior selection per [06]'s "at most one selected snake per operator" invariant [06-REQ-019]). Click-and-drag and double-click are unbound on snake cells in member mode.

**Coach inspection gesture** (08-REQ-052c, 08-REQ-052d). In coach mode the click gesture on a snake body is **not** click-to-select; it is `Shift+Click` (or alternatively `right-click` opening a context menu with "Inspect" as the only entry), with cursor and hover treatment visibly distinct from member mode. A plain click on a snake in coach mode does nothing, so a coach can never accidentally trigger a (no-op) selection-style action that a viewer might misread as an attempt to take control of the team's snake. Pressing `Escape` clears inspection. The coach's inspection visual indicator (layer 7 above) cannot be confused with an operator's selection shadow because the rendering is structurally different (dashed magenta ring vs solid coloured glow) and is rendered only on the coach's own client (08-REQ-052c — inspection is purely client-local).

---

### 2.8 Live Operator Interface — Header

**Header layout** (08-REQ-032, 08-REQ-033, 08-REQ-035, 08-REQ-036, amended per 08-REVIEW-011):

```
┌──────────────────────────────────────────────────────────────────────────────┐
│  Turn N  │  Clock 12.3s  │  Budget 4m17s  │  Net 28ms  │  ●●●○○  │ [Submit] │
└──────────────────────────────────────────────────────────────────────────────┘
   ↑          ↑                ↑                ↑           ↑          ↑
   turn       team clock       remaining        net         presence   Captain
   number     (sub-second)     time budget      latency     + ready    only
```

**Turn number** (08-REQ-032). Read from SpacetimeDB's current-turn subscription field per [04]'s exported subscription pattern.

**Team clock countdown** (08-REQ-033). Sub-second precision: `seconds.tenths` format (e.g., `12.3s`). Below a configurable threshold (default 1.0 s) the rendering enters a warning state (red colour, slightly larger). When the team's turn has been declared over per [01-REQ-039] — observed via SpacetimeDB's `turnEndTime` field collapsing or the dedicated turn-over signal exposed by [04] §2.5 — the countdown is replaced by a static "turn submitted" indicator until the next turn begins; it does not flicker back to a live countdown while other teams declare (08-REQ-033). The animation uses `requestAnimationFrame`-driven local interpolation between authoritative SpacetimeDB updates so the rendered countdown advances smoothly without requiring per-tick subscription deliveries.

**Remaining time budget**. Read from SpacetimeDB's per-team time-budget field per [04]; rendered as `m:ss` because budgets are minutes-scale.

**Network latency** (08-REQ-036). Computed per §2.5; rendered as `Net Nms` with a colour ramp degrading at higher values.

**Presence display** (08-REQ-032, 08-REQ-035, 08-REQ-064a). Shows each *other* connected operator (the local user's own presence is implicit and is conveyed by their own per-operator ready-state toggle and their own selection state on the board). For each entry:
- A coloured dot of the operator's per-operator stable colour (§3.3).
- The operator's display name on hover or always-visible per design discretion.
- A ready-state indicator next to the dot: filled circle (●) if `ready`, hollow circle (○) if `not-ready`. The local user's own ready-state is rendered separately as the toggle of §2.10.
- A role badge for coaches (`C`) and admins (`A`) per 08-REQ-064a; member operators get no badge. Coach/admin entries render no ready-state indicator (they have no ready-state per 08-REQ-064a) and a slightly different visual styling so a viewer can never mistake an admin's connectedness for a member's quorum contribution.

**Captain control affordances** (08-REQ-032, §2.10). Shown only when `role === "captain"`; rendered as a single right-aligned "Submit Turn" button with keyboard binding (08-REQ-066) to `Ctrl+Enter` (or `Cmd+Enter` on macOS) — a chord chosen because it cannot be triggered accidentally during direction-key play (the four arrow keys are reserved for move staging per 08-REQ-045).

---

### 2.9 Live Operator Interface — Drive Management and Decision UX

**Drive dropdown** (08-REQ-052, 08-REVIEW-021). The dropdown's options are computed as `heuristic_config ∩ HEURISTIC_REGISTRY` filtered to `heuristicType === "drive"`, then ordered:
1. Pinned heuristics in the order specified by `global_centaur_params.pinnedHeuristics`.
2. Remaining heuristics lexicographically by `nickname`.
3. Tiebreaker by `heuristicId`.

The intersection is computed at render time from the live `heuristic_config` Convex query and the build-time `HEURISTIC_REGISTRY` import. Drive entries that are in the registry but not yet in `heuristic_config` are not visible in the dropdown until the lazy-insert of §2.11 runs on a Captain visit to the global centaur params page; conversely, stale `heuristic_config` rows whose IDs are no longer in the registry are not visible in the dropdown (they are visible only on the global centaur params page where the Captain can see and delete them per §2.11).

**Eligibility filtering for targeting** (08-REQ-053). After the operator selects a Drive type, the board enters targeting mode for that Drive's `targetType` ([07] §3.1). Eligibility is computed by calling the Drive's `targetEligibility(candidate, self, board)` predicate ([07] §3.2) over every candidate snake or cell. Eligible candidates are rendered with a highlight; ineligible candidates are dimmed. Clicking an eligible candidate confirms; clicking an ineligible one is a no-op; pressing `Escape` cancels targeting without altering selection state (08-REQ-054).

**Tab cycle** (08-REQ-054). Pressing `Tab` while in targeting mode advances the highlighted candidate through the eligible set in the deterministic three-key order specified by 08-REQ-054:
1. **Primary**: A*-distance from the selected snake's head, ascending. A* runs on the current pre-turn board against passable cells; cell candidates use their own coordinates, snake candidates use their head coordinates.
2. **Secondary**: clockwise angle in board coordinates from the snake's current head direction, starting at 0° (straight ahead) and increasing through 360°.
3. **Tertiary**: target identity. For snake targets: snake id ascending. For cell targets: row-major (row ascending, then column ascending).

Computed once at targeting-mode entry from a snapshot of the eligible set + board state and cached for the duration of targeting; if the eligible set or board changes during targeting (e.g., a foreign turn declaration mid-targeting) the cycle is invalidated and recomputed. `Shift+Tab` cycles in reverse using the same key order.

**Confirmation and weight** (08-REQ-055). Confirming a target dispatches `addDriveToSnake({ snakeId, heuristicId, target, weight: defaultWeight })` per [06-REQ-015] using the registry's `defaultWeight` if the team's `heuristic_config` has not overridden it (precedence: `heuristic_config.weight` if present, else `HEURISTIC_REGISTRY` entry's `defaultWeight`).

**Active Drive list** (08-REQ-056). Displayed in the snake's control panel as a list of cards; each card binds to a single `snake_drives` row ([06]) and exposes weight edit (range 0..1, step 0.01), activation toggle, and remove. Edits dispatch [06-REQ-015]'s mutation; the framework reacts per [07-REQ-015] without any client-side coordination required.

**Decision breakdown table** (08-REQ-059, 08-REQ-060). Renders one row per heuristic active on the selected snake with columns: name, raw output (from `SnakeBotStateSnapshot.heuristicOutputs[direction][heuristicId]` per [07] §3.4), portfolio weight (from `snake_drives` / `heuristic_config`), weighted contribution (`output × weight`), and relative impact (the contribution divided by the direction's total score). Updates reactively on every `SnakeBotStateSnapshot` write and on operator switches between selected directions. Per [07] §3.7 DOWNSTREAM IMPACT no-recompute rule, the table renders **purely** from the framework's published `heuristicOutputs` snapshot — no client-side re-evaluation, no interpolation, no carry-over from a prior turn's snapshot. Missing `(direction, heuristicId)` entries render as `—`.

**Worst-case world preview** (08-REQ-048, 08-REQ-050, 08-REQ-051). When a direction is selected for an owned snake, the worst-case overlay (layer 6, §2.7) reads `SnakeBotStateSnapshot.worstCaseWorlds[direction]` per [07] §3.4 and renders the `state` field as a translucent overlay. The per-snake turn-timestamp field on `SimulatedWorldSnapshot` per [07] §3.4 is used to mark snakes whose `perSnakeTurnTimestamp[snakeId] < simulatedTurn` as visually frozen (e.g., a small "held in place" badge or a slightly desaturated rendering), per [07] §3.7's recommendation to surface this distinction. The annotations rendering of 08-REQ-049 is deferred per the 08-REVIEW-023 cascade noted in §2.7 layer 6 — the framework no longer publishes a `WorldAnnotations` payload, so this design pass renders no per-direction annotations until 08-REVIEW-023 is resolved. Updates to the simulated `state` and to the per-snake turn timestamps are driven entirely by the reactive snapshot subscription (08-REQ-050).

---

### 2.10 Per-Operator Ready-State and Captain Controls

**Ready-state toggle UI** (08-REQ-061, 08-REQ-063). The local operator's ready-state toggle is a prominent control adjacent to the header presence display, rendered as a two-state switch with explicit labels (`Not Ready` / `Ready`). Toggling dispatches the `setOperatorReady({ centaurTeamId, gameId, ready })` mutation per [06-REQ-040b]. The toggle remains active throughout the turn (08-REQ-063); the underlying mutation is idempotent so duplicate toggles are harmless. On every new-turn boundary the local toggle resets visually to `Not Ready` (08-REQ-064), driven by the reactive `operator_ready_state` subscription per [06-REQ-043] which is reset upstream by [06-REQ-040b]'s per-turn reset semantics.

**All-ready quorum visualisation** (08-REQ-062). The header presence display's per-operator ready-indicators collectively visualise the unanimity quorum: when every connected member operator (excluding coaches/admins per 08-REQ-064a) shows `●`, the Captain control area additionally shows a small "All Ready — automatic submission armed" indicator. This is a pure visualisation; the actual gating semantics live in [07-REQ-044] / [07-REQ-045] and the flush in [04]'s `declare_turn_over`.

**Coach/admin exclusion from quorum** (08-REQ-064a). The presence display's role badges (`C`/`A` per §2.8) implicitly exclude coach/admin entries from the quorum visualisation: their entries render no ready-indicator at all, so a viewer counting "filled vs hollow" naturally ignores them. The underlying `operator_ready_state` table per [06] also has no row for coaches/admins because they never call `setOperatorReady`.

**Captain turn-submit affordance** (08-REQ-065, 08-REQ-066, 08-REQ-067). Visible in the header only when `role === "captain"`. Clicking the button (or pressing the keyboard binding) calls SpacetimeDB's `declare_turn_over` reducer ([04] §2.5) directly; per [07] §3.7's flush-suppression coordination note, the bot framework observes the resulting turn transition through its existing SpacetimeDB subscription and applies 07-REQ-045a's flush suppression on its own — no out-of-band channel from the UI to the framework is opened. Non-Captain operators do not see the affordance and cannot reach the underlying reducer through the UI; even if they construct a synthetic call, [06]'s function contract surface rejects per [06-REQ-031] (08-REQ-067).

**Action-log emission** (08-REQ-068). `setOperatorReady` writes the `operator_ready_toggled` action-log entry per [06-REQ-040b]. `declare_turn_over` writes the team-side turn-submission entry per [06-REQ-036]. No additional client-side action-log writes are issued from the header.

---

### 2.11 Heuristic Configuration Page

**Page scope** (08-REQ-014). Reads `heuristic_config` for the team via [06-REQ-032]; intersects with `HEURISTIC_REGISTRY` to classify each row as **active** (in both), **stale** (in `heuristic_config` only), or **registry-only** (in registry only). All three classes are surfaced on this page (in contrast to the in-game Drive dropdown of §2.9, which surfaces only active rows).

**Lazy-insert on Captain visits** (08-REVIEW-021). When a user with `role === "captain"` loads this page, the page's `+page.svelte` invokes `insertMissingHeuristicConfig({ centaurTeamId, registrations: getRegisteredHeuristics(HEURISTIC_REGISTRY) })` per [07] §3.7 / [06]'s exported mutation. The mutation is insert-only and never overwrites; previously-Captain-edited values are preserved. The returned `inserted` list is surfaced as a non-blocking toast ("3 new heuristics added to your configuration with their default weights") so the Captain knows the registry has expanded. Non-Captain visitors do not invoke the mutation (they have no Convex auth scope to do so per [06]'s function contract) and see only the current state.

**Edit affordances for Captains** (08-REQ-015, 08-REQ-016, 08-REQ-017). For each registered Preference: an `Active by default` toggle and a `Default weight` numeric input, dispatching to [06]'s `heuristic_config` mutation surface. For each registered Drive type: a `Default weight` numeric input, a `Nickname` text input, and a `Pin` toggle. Pinning is implemented as a Captain-only mutation that updates `global_centaur_params.pinnedHeuristics` per [06-REQ-011] / [06-REQ-007], with adjacent reorder-up/reorder-down arrows on each pinned entry to permute the array. Non-Captain team members see all controls in a disabled state (08-REQ-017, 08-REQ-019).

**Stale entry display** (08-REVIEW-021). Stale entries (in `heuristic_config` but not in the current `HEURISTIC_REGISTRY`) are shown in a distinct visual style (greyed out with an icon and tooltip "no longer registered by this server") and offered a `Delete` affordance that calls [06]'s `deleteHeuristicConfig({ centaurTeamId, heuristicId })` mutation. Deletion is Captain-only per [06]'s function contract.

**"Defaults for future games only" affordance** (08-REQ-018). A persistent banner at the top of the page reads "Edits affect your team's defaults for the **next** game only. Games currently in progress are unaffected." A second-level explanatory tooltip on hover expands to detail the snapshot semantics of [06-REQ-009] / [06-REQ-040a].

---

### 2.12 Bot Parameters Page

**Page scope** (08-REQ-020, amended per 08-REVIEW-011). Reads `global_centaur_params` for the team via [06-REQ-032]. Captain-editable fields per [06-REQ-011]:
- `softmaxTemperature` (slider with numeric input, range per [06]).
- `automaticTimeAllocationMs` (numeric input in milliseconds).
- `defaultScheduledSubmissionIntervalMs` (numeric input in milliseconds, default 100; per [07] §3.5 / [07-REVIEW-012]).
- `defaultImminentThresholdMs` (numeric input in milliseconds, default 50; per [07] §3.5 / [07-REVIEW-012]).
- `pinnedHeuristics` is *not* edited here; it is edited from the heuristic configuration page (§2.11).

The page does **not** expose `defaultOperatorMode` or `turn0AutomaticTimeAllocationMs` (excised per 08-REVIEW-011) and does **not** expose any room/game-config parameter (08-REQ-023).

**Edit gating** (08-REQ-021). Captain-only via [06]'s function contract; non-Captain visitors see read-only values. The same "next game only" banner as §2.11 (08-REQ-022) explains that values are snapshotted into game-scoped state at game start per [06-REQ-040a].

---

### 2.13 Room Browser, Room Creation, and Room Lobby

**Room browser** (08-REQ-024a, 08-REQ-024b, 08-REQ-024c, 08-REQ-024d). Reads from [05]'s rooms query surface. Renders a paginated list with name search; each row links to `/rooms/[roomId]`. The "Create Room" affordance dispatches [05]'s room-creation mutation; on success the user is redirected to the new room's lobby and is its owner per [05-REQ-017] / [05-REQ-019].

**Room lobby** (§8.8). A single page with three logical regions:
1. **Configuration region**: parameter editors for every game-config parameter of [05-REQ-023]. Each editor uses a type-appropriate widget (number with min/max, boolean toggle, enum dropdown) and enforces ranges client-side per 08-REQ-027d. Conditional parameters (08-REQ-027e) are visually nested under their gating parameter and remain editable when the gate is off, but render with a "currently inactive" badge. Parameter edits dispatch [05]'s configuration mutation per [05-REQ-022] / [05-REQ-032b], which both persists the new value and triggers Convex board regeneration (see board preview region). Edits are debounced (default 300 ms) to bound regeneration cadence under rapid editing; this debounce is purely a UX concern and does not relax 08-REQ-027d's authoritative-enforcement-via-Convex posture.
2. **Board preview region** (08-REQ-027i, 08-REQ-027j, 08-REQ-027k, 08-REVIEW-014, 08-REVIEW-015). Subscribes to the not-yet-started game record's `boardPreview` field via Convex's reactive query; renders the field as a miniature SVG board reusing the same renderer as §2.7 in a constrained viewport. The application performs **no** board generation client-side — every preview rendered here is the output of Convex's preview mutation per [05-REQ-032b]. A `Lock In` toggle binds to `boardPreviewLocked` on the game record per 08-REQ-027j and dispatches [05]'s mutation to set/clear the flag. When locked, the preview is annotated visually ("This layout will be used at game start"); when unlocked, the preview annotation reads "Preview only — game start will regenerate from a fresh seed" and the preview continues to update reactively as parameters change.
3. **Enrolment and readiness region** (08-REQ-027a, 08-REQ-027f, 08-REQ-027g, 08-REQ-027h). Displays each enrolled team with its readiness indicator. For each enrolled team where the local user is the Captain, a `Mark Ready`/`Unmark Ready` toggle is shown per 08-REQ-027f / 08-REVIEW-013 (Captain-only); other team members see the indicator read-only. A `Ping Server` button per 08-REQ-027g dispatches a [05]-mediated healthcheck against the team's nominated server and renders the result inline. The "Start Game" button is gated per 08-REQ-027h on `(enrolledTeams.length >= 2) && (every enrolledTeams.ready === true)`; when disabled, the button's tooltip explains which precondition is unmet. Clicking dispatches [05]'s game-start mutation per [05-REQ-031].

**Live spectating link** (08-REQ-027l). When the room has a game in `playing` status, the lobby displays a "Spectate Live" link to `/games/[gameId]/spectate`.

---

### 2.14 Live Spectating

**Entry and token acquisition** (08-REQ-080, 08-REQ-081). On entry to `/games/[gameId]/spectate`, the page calls a Convex action (per [05-REQ-035] / [03] §3.17 spectator path) that returns a spectator SpacetimeDB access token. The token is held in component-local memory only (08-REQ-009a) and used to open the SpacetimeDB connection per [04-REQ-018].

**Subscriptions** (08-REQ-082, 08-REQ-083, 08-REQ-084, 08-REQ-084b, 08-REQ-085, 08-REVIEW-018, 08-REVIEW-019). The spectator subscribes to:
- The current-state subscription per [04] §2.12 spectator pattern (board, snakes filtered by `visible`, items, hazards, fertile tiles, turn events).
- The full historical state up-front per [04-REQ-054]'s mid-game-join pattern (08-REQ-087, 08-REVIEW-019), accepting bounded entry latency proportional to game length. Games are bounded to a few hundred turns; up-front delivery is acceptable per the explicit user tolerance.
- The dedicated `scoreboard_view` per game per [04] §2.9 (resolved by [04]-REVIEW-020 / [04-REQ-071]), which publishes `(turn, centaurTeamId, teamScore, aliveSnakeCount, aggregateLength)` computed server-side over the true alive-snake set including invisible snakes. Subscribed with `WHERE turn = currentTurn` for the live view per [04] §2.12.1, and over the full table for the historical scrubber per [04] §2.12.4.

**Rendering**. The board renderer of §2.7 is reused with the spectator data source (no selection layer, no candidate-highlight layer, no worst-case overlay). Invisibility is honoured purely by the absence of subscription deliveries (08-REQ-083); the application does not attempt to infer hidden state. The scoreboard renders the `scoreboard_view` aggregates verbatim with no client-side aggregation (08-REQ-084, 08-REQ-084b). The header displays the per-team chess-timer state and per-team turn-declared status from [04]'s subscription (08-REQ-085).

**Timeline scrubber** (08-REQ-087, 08-REQ-088). A single timeline control along the bottom of the view permits navigation to any previously completed turn. Scrubbing backward switches the rendering to the historical reconstructed state at the chosen turn while keeping the live subscription open in the background; the view shows a prominent "Viewing Turn N — not live" banner with a "Return to Live" button (08-REQ-088). Returning to the live head dismisses the banner and resumes live rendering.

**Spectator-to-coach-mode entry** (08-REQ-052a). When the local user is a designated coach (per [05-REQ-067]) or admin (per [05-REQ-066]) for a participating team, the spectator view displays a per-team "Enter Coach Mode" link to `/games/[gameId]/coach/[teamId]`. The link is hidden for users with no coach scope on any participating team.

**Negative surface** (08-REQ-086). The spectator view contains no mutating affordance — no selection, no move staging, no ready-state toggle, no Captain control. The spectator data source has no mutation surface (analogous to the replay binding's structural prevention).

**Teardown** (08-REQ-089). Navigating away or observing `game.status === "finished"` releases the SpacetimeDB subscription and discards the spectator access token.

---

### 2.15 Unified Replay Viewer

**Mode selection** (08-REQ-069, 08-REQ-070, 08-REQ-071, 08-REQ-071a). The viewer's data source is selected on entry by the URL: `/games/[gameId]/replay` opens in board-level mode by default; `/games/[gameId]/replay?mode=team` opens in team-perspective mode if the viewer participated as a team member of one of the participating teams. Both modes share the unified timeline control (§2.15.1 below) and the data-source abstraction's replay binding (§2.4). Board-level mode binds with `participatingTeam: null`, scoping the action-log reconstruction to none (board-level mode renders no Centaur-subsystem state per 08-REQ-075b). Team-perspective mode binds with `participatingTeam: teamId`, scoping action-log reconstruction to that team only (08-REQ-075a's RLS-honouring posture is preserved by the action log's own team-scoping).

**Component reuse** (08-REQ-071, 08-REQ-077). Team-perspective mode reuses the same `<BoardDisplay>`, `<DriveManagementPanel>`, `<DecisionBreakdownTable>`, `<WorstCaseWorldPreview>`, and `<HeaderPresence>` components as the live operator interface; the data-source binding of §2.4 makes their mutating affordances structurally absent in replay mode (no mutation surface exists), so each component renders read-only without per-component branching. Inspection is wired in per the inspection provider of §2.4 (08-REQ-074, 08-REQ-075).

**Board-level rendering** (08-REQ-070, 08-REQ-070a, 08-REQ-070b). Board-level mode renders the public board state at the scrubbed turn (cells, snakes, items, hazards, fertile tiles, scoreboard) plus the per-turn event log. Visual consistency with the live spectating view is preserved by reusing the renderer of §2.7. Per 08-REQ-070, no SpacetimeDB consultation occurs — all data is sourced from the persisted replay of [05-REQ-040].

**Historical selection shadows** (08-REQ-073). Team-perspective mode renders the operator selection state at the scrubbed timestamp as per-operator coloured shadows on the appropriate snakes, reconstructed from the action log. Operators not connected at the scrubbed moment produce no shadow.

**Direct link** (08-REQ-075c). The viewer exposes a "Copy Link" affordance that produces the absolute URL `/games/[gameId]/replay` (or `?mode=team` if the viewer is in team-perspective mode); clicking the link from another authenticated user lands them in the viewer for the same game.

#### 2.15.1 Unified Timeline Control

**Per [08-REVIEW-010]**. The timeline control exposes a Per-Turn / Timeline mode toggle and per-mode scrubbing semantics, keyboard navigation, turn-marker rendering, and playback-speed sets per 08-REQ-072 through 08-REQ-072d.

**State**. The control owns three pieces of client-local UI state:
- `mode: "per-turn" | "timeline"` (default `per-turn` per 08-REQ-072a).
- `speedPerTurn: 0.25 | 0.5 | 1 | 2 | 4 | 8` (turns per second).
- `speedTimeline: 0.25 | 0.5 | 1 | 2 | 4 | 8` (× real time).

All three are persisted in `sessionStorage` (per 08-REQ-072a — client-local, not Convex) and restored on subsequent navigation within the same session.

**Per-Turn mode rendering** (08-REQ-072b). The scrubber is rendered as N equidistant tick marks where N is the total turn count. Scrubbing snaps to the nearest tick (the end of each turn). Playback advances the cursor by one turn per tick at the configured rate. The speed widget label reads "N turns/s".

**Timeline mode rendering** (08-REQ-072c). The scrubber's horizontal axis is wall-clock time from `gameStartTime` to `gameEndTime` (sourced from the persisted replay metadata per [05-REQ-040]). Turn boundaries are rendered as turn-marker glyphs at their actual `turnDeclaredAt` clock positions (read from the replay's per-turn metadata) — explicitly non-equidistant, reflecting variable chess-clock duration. Scrubbing is continuous along clock time. Playback advances at the chosen scalar multiple of real time. The speed widget label reads "N× speed".

**Keyboard navigation** (08-REQ-072d). Bound on `keydown` while the viewer has focus:
- Timeline mode: `Left`/`Right` → ±1000 ms; `Shift+Left`/`Shift+Right` → ±200 ms; `Ctrl+Left`/`Ctrl+Right` (interpreted as `Cmd` on macOS) → snap to previous/next turn-marker.
- Per-Turn mode: `Left`/`Right` → ±1 turn. Modifier-key bindings in Per-Turn mode are deferred per 08-REQ-072d (not bound in the reference implementation; forks may bind freely).

`Space` toggles play/pause in both modes.

---

### 2.16 Coach Mode

**Entry points** (08-REQ-052a). `/games/[gameId]/coach/[teamId]` is reached from:
- The Live Spectating view's "Enter Coach Mode" link (§2.14).
- The Team Profile view's in-progress game indicator when the user is a designated coach or admin.

The route's load function verifies the user holds a coach scope on `[teamId]` per [05-REQ-067] (or implicit-coach permission per [05-REQ-066]); if not, the route refuses with a 403-equivalent empty state.

**Token acquisition**. The coach data source per §2.4 is constructed via `createCoachDataSource({ gameId, centaurTeamId, coachToken })`, where `coachToken` is obtained via the coach SpacetimeDB token issuance path of [05] §3.4 ([05-REQ-067]).

**Cross-server applicability**. Because coach mode reads only via [05]'s coach token issuance (which any Snek Centaur Server's frontend can request given a valid coach scope) and via [05]/[06] subscriptions (which are not server-pinned), coach mode is **cross-server**: any frontend served by any Snek Centaur Server in the platform can render coach mode for any team the user has coach scope on, regardless of which server hosts the team's bot framework. This contrasts with the member live operator interface (08-REQ-028, §2.2 cross-server reachability), which requires the team to be hosted by *this* server because the bot framework's per-team session is co-resident.

**Rendering**. The coach view renders the same component tree as the live operator interface (board display, header, Drive management panel, decision breakdown table, worst-case world preview, presence display, action log). All mutating affordances are structurally absent because the coach data source exposes no mutation surface (08-REQ-052b); inspection replaces selection per the inspection provider (08-REQ-052c, §2.7's coach inspection gesture). Operator selection shadows produced by team members remain visible (08-REQ-052c). The presence display includes the coach with role badge `C` (or `A` for admins) per §2.8.

---

### 2.17 Platform Pages

**Home view** (08-REQ-010a). A single page composed of three sections: (1) "My Teams" listing the user's current Centaur Team memberships per [05-REQ-011]; (2) "Recent Rooms" listing the most recently visited rooms (sourced from a small Convex side-table or, equivalently, from a client-local `localStorage` history that is non-authoritative — design discretion picks `localStorage` because it requires no schema addition and the recency list is purely a UX convenience); (3) "Games in Progress" listing every game with `status === "playing"` in which any of the user's Centaur Teams is participating, with each entry deep-linking to `/teams/[teamId]/live` on the team's nominated server (cross-server URL per §2.2).

**Teams browser** (08-REQ-023a). Lists every team per [05-REQ-008] with name, display colour swatch, and current Captain display name; each row links to `/teams/[teamId]`.

**Team Management** (08-REQ-023b through 08-REQ-023f). The view splits affordances by role: every member sees identity, members list, coaches list, server health; the Captain additionally sees mutating affordances for name, colour, server domain, member add/remove, coach add/remove (calls [05]'s `addCoach` / `removeCoach` per 08-REQ-023d), and Captain transfer. All mutating affordances render disabled with explanatory text while the team's `[05]` mid-game freeze is in effect (08-REQ-023e), driven by a reactive query against [05]'s game-status subscription. The view exposes no bot/heuristic affordances (08-REQ-023f) but links to `/teams/[teamId]/heuristic-config` and `/teams/[teamId]/bot-params`.

**Player Profile** (08-REQ-090, 08-REQ-091, 08-REQ-091a, 08-REQ-092, 08-REQ-093, 08-REVIEW-016). Renders display name, current and historical team memberships, game history per the historical-or-current rule (08-REQ-091), aggregate stats. The page never references the user's email at any visibility — neither for the viewing user nor the profile owner (08-REQ-091a). Historical attributions resolve via the participating-team snapshot per [05-REQ-029], so an archived team continues to render under its historical identity (08-REQ-093, 08-REQ-103).

**Team Profile** (08-REQ-094 through 08-REQ-098). Renders identity, members, server health, full game history, aggregate stats, head-to-head records. Game history includes every game the team participated in (cross-team-public per 08-REQ-095). Historical opponent attributions resolve via participating-team snapshots (08-REQ-097). The view is purely informational — no mutating affordances (08-REQ-098) — and links to `/teams/[teamId]/manage` for users with the appropriate scope.

**Leaderboard** (08-REQ-094a through 08-REQ-094f). Renders a ranked list per a chosen criterion × time-window × optional room filter, with archived teams retained under their historical identity (08-REQ-094e). Each entry links to its Team Profile (08-REQ-094d). Authentication is required (08-REQ-094f); no email is exposed (08-REQ-091a).

**API Key Management** (08-REQ-095a through 08-REQ-095d). Lists the user's active and revoked keys with label, creation timestamp, and revocation timestamp. The "Create API Key" action opens a modal that, on Convex acknowledgement of [05-REQ-051]'s creation, displays the plaintext exactly once with a "Copy to clipboard" button; dismissing the modal discards the plaintext (08-REQ-095b, 08-REQ-095c). A persistent informational banner explains that the key's authorisation scope is bounded by the user's own current scope per [05-REQ-047] (08-REQ-095d).

**Admin experience** (§8.21, 08-REQ-096a, 08-REQ-096b, 08-REQ-009c). When `user.role === "admin"`:
- The Teams browser lists all teams regardless of membership ([05-REQ-066]).
- The home view's "Games in Progress" expands to include all platform games (admin discretion).
- Replay viewer and coach-mode entry points are unconditionally available for any team in any game.
- An `/admin` landing page links to admin-only utility views (e.g., a system healthcheck dashboard).

The admin experience is read-only with respect to game state and Centaur-subsystem state (08-REQ-096b); admin actions never include staging moves or editing Centaur state for teams the admin is not a member of.

---

### 2.18 Error Handling and Invariant Rejection Display

**Convex rejection feedback path** (08-REQ-100). Every mutation dispatched through the data source returns a `Promise<Result>` whose rejection branch carries the Convex-side error code and message. The application maintains a singleton toast bus (Svelte 5 store) that surfaces user-legible error messages anchored to the affordance that triggered them. Rejections are translated through a `convexErrorToHumanMessage(error)` helper that maps known Convex error codes to user-legible English strings; unknown errors render the raw Convex message verbatim with a "report issue" affordance. The UI never silently swallows a rejection.

**Affordance enablement derivation** (08-REQ-101). Every affordance whose enablement is governed by a Convex-side invariant computes its `disabled` state from a Svelte 5 `$derived` rune over the relevant Convex reactive subscription. Examples: the room lobby's "Start Game" button is `$derived` from enrolled-teams count and per-team readiness; the Team Management view's mutating affordances are `$derived` from the team's mid-game-freeze status; the heuristic config page's Captain affordances are `$derived` from the role rune of §2.3. Where derivation is impossible (the invariant lives only inside a Convex mutation handler), the UI dispatches the mutation and routes the result through the §2.18 feedback path per 08-REQ-101's fallback clause.

**Parameter snapshot vs defaults display** (08-REQ-102). Every view that surfaces a game's configuration reads the configuration from the game record's snapshot per [05-REQ-024], not from the room's current defaults. Room and game configuration views are explicitly distinct components in the codebase (`<RoomConfigEditor>` vs `<GameConfigViewer>`) so the two values cannot accidentally be confused at render sites.

**Subscription loss surfacing** (08-REQ-083a). Each data source observes its underlying subscription's connection state and, on loss, emits a `subscriptionLost` event that the surrounding UI surfaces as a banner ("Connection lost, attempting to reconnect…"). Stale state is not fabricated; the affected components render their last-known values dimmed with a "stale" indicator, or render a placeholder if no value has ever been received. On recovery, the subscription resubscribes and the UI returns to fresh rendering.

---

### 2.19 Lifecycle and Session Boundaries

**Live operator interface availability** (08-REQ-081a, 08-REQ-082a). The team-scoped layout's reactive query against `game.status` drives the `/teams/[teamId]/live` route's lifecycle: on the transition to `playing` the live operator interface mounts; on the transition to `finished` the interface unmounts and is replaced by a terminal state component showing final scores per [05-REQ-038] and a link to `/games/[gameId]/replay`. Mid-session lifecycle is purely reactive — no manual page navigation is required for either transition.

**No client-side authoritative state** (08-REQ-084a). The application persists no authoritative state to client storage: `sessionStorage` holds only the timeline-control mode/speed preferences (§2.15.1), and `localStorage` holds only the home view's recent-rooms list (a UX convenience, non-authoritative). All operator-visible state derives from [04], [05], or [06] on every session, consistent with [07-REQ-057]'s posture for the framework.

---

### 2.20 Requirement Coverage Addendum

The following design elements are short, citation-bearing notes for requirements whose substantive design is implicit in the architectural choices of §§2.1–2.19 or upstream-module exported interfaces but which warrant an explicit citation for traceability.

- **Application scope** (08-REQ-001). The entire Design and Exported Interfaces sections of this module describe the unified human-facing web application of the Snek Centaur Platform; there is no separate "Game Platform" web application. §2.1's stack and topology, §2.2's routing topology covering both team-internal and platform-wide surfaces, and §3.6's library-surface table jointly satisfy the scope claim.
- **Live-game prominence on navigation surface** (08-REQ-011). The home view's "Games in Progress" section (§2.17) lists every game with `status === "playing"` in which any of the user's Centaur Teams is participating, deep-linking to `/teams/[teamId]/live` on the team's nominated server. Additionally, the global header's primary navigation surface renders a persistent badge ("Live: 〈team name〉") for any hosted team currently in a `playing` game, derived reactively from the same Convex subscription, so an operator returning to the application lands on the live surface in one click without navigating into the team page first.
- **Team creation affordance** (08-REQ-023c). The `/teams` browser (§2.17) exposes a primary "Create Team" button visible to every authenticated user; clicking dispatches [05]'s team-creation mutation per [05-REQ-008] / [05-REQ-011] and, on success, redirects the creator (now Captain per the same mutation) to the new team's `/teams/[teamId]/manage` view.
- **Team game history view** (08-REQ-024, 08-REQ-025, 08-REQ-026, 08-REQ-027). The `/teams/[teamId]/games` route (§2.2) renders a reverse-chronological list of completed games filtered to the (a)/(b) eligibility set of 08-REQ-024 against the participating-team snapshot of [05-REQ-029]. Each row shows room name, date, opponent teams, the team's result, and final scores per [05-REQ-038] (08-REQ-025). Selecting a row navigates to `/games/[gameId]/replay?mode=team` defaulting to the team-perspective sub-turn view (08-REQ-026). The route's load function applies the negative gate of 08-REQ-027 by computing the eligibility set in the Convex query, so unrelated teams' games are never returned to the client.
- **Room lobby read-only access for non-enrolled viewers** (08-REQ-027b). The room lobby route (§2.13) is reachable by every authenticated user; its layout binds every mutating affordance's `disabled` state to `$derived(role !== "owner" && !memberOfEnrolledTeam)`. Non-eligible viewers see the full lobby state — configuration, board preview, enrolled teams, readiness — but no editable widget.
- **Owner/administrative-actor lobby affordances** (08-REQ-027c). The room lobby's owner-only affordance set is rendered when the layout-derived `isAdministrativeActor` flag is true, where the flag mirrors [05-REQ-017]'s definition (the room owner, or any authenticated user when no owner exists per [05-REQ-018]). Affordances exposed: every game-configuration parameter editor of [05-REQ-023] within its declared range (§2.13's configuration region), invite/remove enrolment controls, abdicate-ownership control per [05-REQ-018], and "Start Game" per 08-REQ-027h / [05-REQ-031].
- **Selection vs manual mode** (08-REQ-029). Per §2.7's click-to-select gesture, the `selectSnake` mutation modifies only the selection record in [06]; it does not write `manual=true` to the snake's `snake_drives` / Centaur state. The data-source abstraction's `selectSnake` mutation (§3.2) and `setManualMode` mutation are deliberately separate so this property holds at the type level.
- **Manual-mode entry/exit invariants** (08-REQ-030). The data-source abstraction (§3.2) exposes both `setManualMode({ manual: true | false })` and `stageMove({ direction })`; the live binding's `stageMove` implementation in `@snek-centaur/server-lib` performs an atomic `setManualMode(true) ⊕ stageMove` per [06-REQ-025]'s side-effect requirement. Unchecking the manual checkbox dispatches `setManualMode({ manual: false })` and the framework's automatic submission pipeline resumes per [07-REQ-040]. The UI never invents a third manual-mode entry path.
- **No client-side scheduler logic** (08-REQ-031). The data-source abstraction publishes no compute-scheduling control surface; component code consumes published `SnakeBotStateSnapshot` values reactively and adds no scheduler hint of its own. Compute scheduling lives entirely in [07-REQ-040]'s framework-side priority pipeline.
- **08-REQ-034 reservation note**. 08-REQ-034 is reserved per its own text (removed during 08-REVIEW-011 resolution); the design surface that satisfies the requirement's behavioural intent is the per-operator ready-state design of §2.10, which renders coordination state as per-operator presence per [08-REQ-032] and [06-REQ-040b]. No additional design element is needed.
- **Direction-candidate gating on selector ownership** (08-REQ-043). The Drive management panel and move interface (§§2.7, 2.9) bind their root visibility to a `$derived` rune over `dataSource.snakeOperatorStates` filtered to `selectedBy === currentUserId`; non-selecting viewers see no candidate-direction interaction surface at all. Clicks on layer 5 candidate highlights are bound only when this derivation is truthy, structurally satisfying the negative requirement.
- **Move interface direction buttons** (08-REQ-044). The move interface renders four direction buttons (Up, Down, Left, Right), each labelled with its direction's stateMap score read from `SnakeBotStateSnapshot.stateMap[direction]` per [07] §3.4 / [07-REQ-035] and coloured to match the layer-5 candidate highlight monotone ramp of §2.7. The currently-staged direction is rendered with an additional "staged" visual treatment by reading from `dataSource.stagedMoves`. Immediately-lethal directions per [01-REQ-044a] / [01-REQ-044b] are visually disabled (greyed) yet remain selectable as last-resort candidates per [07-REQ-019]; the data source's `stageMove` mutation does not refuse these directions.
- **No separate commit affordance** (08-REQ-046). The move interface emits a `stageMove` mutation on each direction-button click; there is no "commit" button, no two-phase submit. The user-visible affordance design uses tense-shifted labels ("Stage Up" rather than "Commit Up") and a small banner under the four buttons ("Each click immediately stages — there is no separate commit step. Your turn ends when your team's Captain submits or the clock runs out.") to satisfy the awareness clause of 08-REQ-046.
- **Manual checkbox** (08-REQ-047). The owned-snake control panel renders the `Manual` checkbox whenever the data source's `selectedBy === currentUserId` derivation is truthy. Its checked state binds to `snake_drives.manual` per [06-REQ-018] via the data source. Toggling on dispatches `setManualMode({ manual: true })` only — without an accompanying `stageMove`, so the currently-staged direction (whether bot-staged or human-staged) is preserved per the requirement's lock clause. Toggling off dispatches `setManualMode({ manual: false })`, returning the snake to the framework's submission pipeline.
- **Persistence of Drive overrides across selection changes** (08-REQ-057). The Drive management panel reads from [06]'s `snake_drives` rows, which persist independent of selection per [06-REQ-016]. The UI never issues a destructive write on selection change; switching selected snake mounts a new `<DriveManagementPanel>` against the new snake's rows, leaving the prior snake's rows untouched. Per-snake temperature override (where applicable per [06]) is persisted to [06] in the same manner.
- **Negative: no UI affordance for unregistered Drives** (08-REQ-058). The Drive dropdown's source set (§2.9) is the intersection `heuristic_config ∩ HEURISTIC_REGISTRY`; the UI never offers an "add new Drive type" affordance and never accepts free-form `heuristicId` input. New Drive types enter the system only via code-level expansion of the team's `@team-snek/heuristics` source per [06-REQ-005] and the lazy-insert path of §2.11.
- **Leaderboard time-window and room filters** (08-REQ-094b, 08-REQ-094c). The Leaderboard view (§2.17) exposes (a) a criterion selector binding to the criteria set of [08-REQ-094a], (b) a time-window selector with the closed set `{all time, last 30 days, last 7 days}`, and (c) an optional room-filter typeahead bound to [05]'s rooms query. Each selection re-issues the leaderboard's Convex query with the corresponding parameters; the ranking computation lives Convex-side.
- **Team Profile aggregate statistics** (08-REQ-096). The Team Profile view (§2.17) renders aggregate statistics derived from the team's full game history: games played, win rate, average score, and head-to-head records against every opponent team the team has ever played. Aggregates are computed Convex-side (no client aggregation, mirroring the discipline of 08-REQ-084b / 08-REVIEW-018) and surfaced on the profile alongside the per-game history.

---

## Exported Interfaces

Module 08 has no downstream module per the dependency graph (Module 09 is absorbed into 08). The exported interfaces enumerated here are nonetheless load-bearing for fork authors and for the upstream contracts the application participates in (the invitation envelope from [05] / [03], the lazy-insert payload to [06] / [07]).

### 3.1 Game Invitation Endpoint Contract

Motivated by 08-REQ-005. The endpoint is the platform's load-bearing contact point between Convex (which sends invitations) and the Snek Centaur Server (which accepts them).

```typescript
// POST /.well-known/snek-game-invite
// Content-Type: application/json

export interface SnekGameInviteRequest {
  // The full invitation envelope as defined by [03] §3.16.
  // Carries the per-Centaur-Team game credential JWT (issued by Convex Auth's
  // customJwt provider per [03] §3.15), the targeted (centaurTeamId, gameId),
  // and the SpacetimeDB instance coordinates.
  readonly envelope: GameStartInvitationEnvelope     // [03] exported type
}

export interface SnekGameInviteResponse {
  readonly accepted: true
  readonly alreadyAccepted: boolean                  // true iff this (team, game) was previously accepted
  readonly serverInstance: {
    readonly serverDomain: string                    // echoes back this server's nominatedServerDomain
    readonly hostedTeamCount: number                 // operational visibility for [05]
  }
}

// Failure responses use HTTP status codes 401 (signature invalid),
// 403 (team not hosted by this server), 500 (bot framework boot failed).
// All failure bodies are { error: string, code: string }.
```

### 3.2 Data-Source Abstraction

Motivated by 08-REQ-076, 08-REQ-077, 08-REQ-078. This is the load-bearing surface between `@snek-centaur/server-lib` and the forked operator UI; replay-mode and coach-mode bindings structurally lack a mutation surface so component code cannot accidentally mutate (08-REQ-078, 08-REQ-052b).

```typescript
import type {
  GameState, SnakeId, Direction, Cell,
} from "@snek-centaur/engine"
import type {
  SnakeBotStateSnapshot,
} from "@team-snek/bot-framework"
import type {
  ActionLogEntry, SnakeOperatorState,
  HeuristicConfigRow, GameCentaurStateView,
  OperatorReadyState,
} from "@snek-centaur/server-lib"      // re-exports [06]'s exported view types

// ───────────────────────────────────────────────────────────────────────────
// Reactive read signals — common to all three bindings.
// Each property is a Svelte 5 readable rune (subscribe to the rune in a
// component's reactive context to read its current value).
// ───────────────────────────────────────────────────────────────────────────

export interface ReadSignals {
  readonly gameId: string
  readonly currentTurn: () => number                                   // [04]
  readonly boardState: () => GameState                                 // [04] / [05] reconstructed
  readonly stagedMoves: () => ReadonlyMap<SnakeId, Direction>          // [04]
  readonly chessTimer: () => {
    readonly perTeamRemainingMs: ReadonlyMap<string /* teamId */, number>
    readonly currentTurnEndAtMs: number | null
  }
  readonly snakeOperatorStates: () => ReadonlyArray<SnakeOperatorState>  // [06] §2.1.2
  readonly snakeBotStates: () => ReadonlyMap<SnakeId, SnakeBotStateSnapshot>  // [06] §2.1.3 / [07] §3.4
  readonly heuristicConfig: () => ReadonlyArray<HeuristicConfigRow>    // [06] §2.1.4
  readonly gameCentaurState: () => GameCentaurStateView                // [06] §2.1.5
  readonly operatorReadyStates: () => ReadonlyArray<OperatorReadyState> // [06] §2.1.5 / 06-REQ-040b
  readonly actionLog: () => ReadonlyArray<ActionLogEntry>              // [06] §2.1.6
  // Connection health is observable so §2.18 can surface subscription loss.
  readonly connectionState: () => "connected" | "reconnecting" | "lost"
}

// ───────────────────────────────────────────────────────────────────────────
// Mutation surface — present only on the live binding.
// ───────────────────────────────────────────────────────────────────────────

export interface LiveMutations {
  selectSnake(args: { snakeId: SnakeId; displace?: boolean }): Promise<MutationResult>
  deselectSnake(args: { snakeId: SnakeId }): Promise<MutationResult>
  setManualMode(args: { snakeId: SnakeId; manual: boolean }): Promise<MutationResult>
  stageMove(args: { snakeId: SnakeId; direction: Direction }): Promise<MutationResult>
  addDriveToSnake(args: {
    snakeId: SnakeId; heuristicId: string;
    target: { kind: "snake"; snakeId: SnakeId } | { kind: "cell"; cell: Cell };
    weight: number;
  }): Promise<MutationResult>
  removeDriveFromSnake(args: { snakeId: SnakeId; driveId: string }): Promise<MutationResult>
  updateDriveWeight(args: { driveId: string; weight: number }): Promise<MutationResult>
  setOperatorReady(args: { ready: boolean }): Promise<MutationResult>
  declareTurnOver(): Promise<MutationResult>          // Captain-only enforced by [06]/[04]
}

export type MutationResult =
  | { ok: true }
  | { ok: false; code: string; message: string }     // surfaced via §2.18

// ───────────────────────────────────────────────────────────────────────────
// Bindings.
// ───────────────────────────────────────────────────────────────────────────

export interface LiveDataSource extends ReadSignals {
  readonly mode: "live"
  readonly mutations: LiveMutations
  dispose(): Promise<void>
}

export interface ReplayDataSource extends ReadSignals {
  readonly mode: "replay"
  readonly scrubber: ReplayScrubberControl              // §3.2.1 below
  // No `mutations` field — structurally prevents replay-mode mutation (08-REQ-078).
  dispose(): Promise<void>
}

export interface CoachDataSource extends ReadSignals {
  readonly mode: "coach"
  readonly coachedTeamId: string
  // No `mutations` field — structurally prevents coach-mode mutation (08-REQ-052b).
  dispose(): Promise<void>
}

export type DataSource = LiveDataSource | ReplayDataSource | CoachDataSource

// Factories produced by @snek-centaur/server-lib.
export function createLiveDataSource(args: {
  gameId: string
  centaurTeamId: string
  gameCredential: string                              // per-Centaur-Team game credential JWT
}): Promise<LiveDataSource>

export function createReplayDataSource(args: {
  gameId: string
  participatingTeamId: string | null                  // null → board-level mode (08-REQ-070b)
}): Promise<ReplayDataSource>

export function createCoachDataSource(args: {
  gameId: string
  centaurTeamId: string                               // the team being coached
  coachToken: string                                  // [05] §3.4 coach SpacetimeDB token
}): Promise<CoachDataSource>
```

#### 3.2.1 Replay Scrubber Control

Motivated by 08-REQ-072, 08-REQ-072a, 08-REQ-072b, 08-REQ-072c, 08-REQ-072d.

```typescript
export interface ReplayScrubberControl {
  readonly mode: () => "per-turn" | "timeline"
  setMode(mode: "per-turn" | "timeline"): void

  // Cursor units differ by mode: turn index in per-turn mode, ms-since-game-start
  // in timeline mode. The data source projects the same underlying state at the
  // cursor position regardless of mode.
  readonly cursor: () => number
  setCursor(value: number): void

  readonly playing: () => boolean
  play(): void
  pause(): void

  readonly speedPerTurn: () => 0.25 | 0.5 | 1 | 2 | 4 | 8
  setSpeedPerTurn(value: 0.25 | 0.5 | 1 | 2 | 4 | 8): void

  readonly speedTimeline: () => 0.25 | 0.5 | 1 | 2 | 4 | 8
  setSpeedTimeline(value: 0.25 | 0.5 | 1 | 2 | 4 | 8): void

  // Turn marker positions for timeline-mode rendering.
  readonly turnMarkers: () => ReadonlyArray<{ readonly turn: number; readonly atMs: number }>

  // Game bounds (timeline mode renders this as the scrubber axis).
  readonly gameStartMs: number
  readonly gameEndMs: number
  readonly turnCount: number
}
```

### 3.3 Per-Operator Stable-Colour Function

Motivated by 08-REQ-035, 08-REQ-039, 08-REQ-073. Used by the header presence display, the board's selection-shadow layer, the action log's per-operator attribution, and the replay viewer's reconstructed selection shadows. Colour must be stable for `(gameId, userId)` across all clients viewing the same game so coloured affordances are recognisable across browsers and reloads.

```typescript
// Returns one of 16 accessibility-screened hex colours, deterministically
// from (gameId, userId). Distribution is balanced via a hash-mix.
export function assignOperatorColour(gameId: string, userId: string): string

// The palette is exported for test/forks; forks may swap palettes provided
// the function remains deterministic in (gameId, userId).
export const OPERATOR_COLOUR_PALETTE: ReadonlyArray<string>     // length 16
```

### 3.4 Presence Channel Shape

Motivated by 08-REQ-032, 08-REQ-035, 08-REQ-064a. Specifies the per-presence-record shape installed in the `@convex-dev/presence` channel keyed `team:${centaurTeamId}:game:${gameId}`. Joined to [06]'s `operator_ready_state` rows reactively.

```typescript
export interface OperatorPresenceRecord {
  readonly userId: string                          // resolves to a User per [05]
  readonly role: "member" | "coach" | "admin"      // 08-REQ-064a quorum exclusion
  readonly displayName: string                     // OAuth display name only (08-REQ-091a)
  readonly colour: string                          // assignOperatorColour(gameId, userId)
  readonly currentSelectionSnakeId: string | null  // mirrors [06]'s snake_operator_state
}

export const presenceChannelKey = (centaurTeamId: string, gameId: string): string =>
  `team:${centaurTeamId}:game:${gameId}`
```

### 3.5 Lazy-Insert Invocation Contract

Motivated by 08-REVIEW-021 and [07] §3.7's DOWNSTREAM IMPACT note. The application invokes [06]'s `insertMissingHeuristicConfig` mutation on every Captain visit to the global centaur params page (§2.11), supplying the registry projection produced by [07]'s `getRegisteredHeuristics`.

```typescript
import { getRegisteredHeuristics } from "@team-snek/heuristics"
import { HEURISTIC_REGISTRY } from "@team-snek/heuristics"

// Invocation signature consumed by [06]'s function contract:
//   insertMissingHeuristicConfig({
//     centaurTeamId,
//     registrations: getRegisteredHeuristics(HEURISTIC_REGISTRY),
//   }): Promise<{ inserted: ReadonlyArray<string /* heuristicId */> }>
//
// Caller authorisation: the Captain's Convex auth credential. Non-Captain
// page visits do not invoke this mutation (08-REQ-017's Captain-only edit rule
// applies symmetrically to inserts).
//
// Idempotence: the mutation is insert-only and never overwrites existing rows.
// Per-team behaviour: invoked at most once per page visit; the returned
// `inserted` list is surfaced to the Captain as a non-blocking toast.
```

### 3.6 Centaur-Lib Library Surface Summary

Motivated by 08-REQ-076, 08-REQ-079, 08-REQ-080a. This is the consolidated list of types and functions a fork must depend on from `@snek-centaur/server-lib` (canonicalisation pending 08-REVIEW-022). Forks may freely modify Svelte components, layouts, routes, and styling; they must not modify or replace the items below if they intend to preserve compatibility with the platform.

| Symbol | Source | Purpose |
|---|---|---|
| `createLiveDataSource`, `createReplayDataSource`, `createCoachDataSource` | §3.2 | Data-source bindings |
| `LiveDataSource`, `ReplayDataSource`, `CoachDataSource`, `DataSource` | §3.2 | Type-level binding contract |
| `ReadSignals`, `LiveMutations`, `MutationResult` | §3.2 | Reactive surface and mutation result |
| `ReplayScrubberControl` | §3.2.1 | Unified timeline control state |
| `assignOperatorColour`, `OPERATOR_COLOUR_PALETTE` | §3.3 | Per-operator stable colour |
| `OperatorPresenceRecord`, `presenceChannelKey` | §3.4 | Presence channel shape |
| `SnekGameInviteRequest`, `SnekGameInviteResponse` | §3.1 | Invitation endpoint contract |
| `convexErrorToHumanMessage` | §2.18 | Convex rejection translation helper |
| `startGameSession` (re-exported from [07] §3.3) | [07] | In-process bot framework boot from invitation handler |

### 3.7 DOWNSTREAM IMPACT Notes

None. Module 08 is a leaf in the dependency graph (Module 09 is absorbed into 08 as a redirect stub). The constraints this module's design imposes on its upstream dependencies are already recorded as DOWNSTREAM IMPACT items in those upstream modules' Phase 2 sections — notably [04]'s `scoreboard_view` per `04-REVIEW-020` (consumed by §2.14) and [06]/[07]'s `insertMissingHeuristicConfig` mutation (consumed by §2.11 and §3.5).

---

## REVIEW Items

### 08-REVIEW-001: Role gating of heuristic configuration and bot parameters — **RESOLVED**

**Type**: Ambiguity
**Phase**: Requirements
**Context**: Informal spec §7.1 and §7.2 both say the heuristic config and bot parameters are "editable by any team member". §8.2 separately says team identity, server registration, and membership are captain-only — an explicit distinction that implies team-internal competitive configuration is deliberately not captain-only. [06-REQ-008] and [06-REQ-012] echo this by requiring only that the caller be a team member. This is a plausible reading but is surprising: a new operator could, immediately upon being added to the team, change the team's global heuristic defaults in ways that affect subsequent games for everyone. No mechanism in the current draft provides a safeguard.
**Question**: Should the heuristic configuration page and the bot parameters page be gated on a role (captain, timekeeper) rather than general team membership?
**Options**:
- A: Any team member can edit. (Current draft, matches informal spec literally.)
- B: Captain-only for both pages.
- C: Captain-or-timekeeper for both pages.
- D: Page is read-only to general members; an "edit mode" affordance requires the captain to promote.
**Informal spec reference**: §7.1, §7.2, §8.2.

**Decision**: Captain-only for team-scoped defaults; any team member for game-scoped overrides. Only the Captain can edit `global_centaur_params` and team-level heuristic defaults in `heuristic_config`. Any team member can edit game-scoped heuristic weight overrides (per-snake Drive weights, Preference activation, temperature overrides during a live game). There is no longer a timekeeper role (eliminated per 05-REVIEW-014).
**Rationale**: Team-scoped defaults (global temperature, default operator mode, heuristic default weights, dropdown ordering) represent strategic decisions that affect all future games for the entire team. Restricting these to the Captain prevents a newly-added operator from unilaterally changing team strategy. Game-scoped overrides, by contrast, are tactical in-game adjustments that operators need to make in real time during gameplay — requiring Captain approval for every weight tweak during a live game would be operationally unworkable. This split aligns with the existing Captain/member distinction in team management (§8.5b) and is consistent with the elimination of the timekeeper role per 05-REVIEW-014.
**Affected requirements/design elements**: 08-REQ-019 amended (team-scoped heuristic defaults are Captain-only). 08-REQ-008 amended (references updated role list). 08-REQ-017 amended (Captain-only for team-scoped mutations). 08-REQ-021 amended (Captain-only for bot params). 06-REQ-008 amended (Captain-only for team-scoped heuristic config writes). 06-REQ-012 amended (Captain-only for bot param writes). Design §2.2.1 authorization updated.

---

### 08-REVIEW-002: Mid-game effect of default-operator-mode edits — **RESOLVED**

**Type**: Gap
**Phase**: Requirements
**Context**: 08-REQ-022 says the default operator mode affects only future games, since the running game's mode is owned by the session's in-memory state and toggled by the timekeeper. But [06-REQ-011] treats the default operator mode as a team-scoped record and [06-REQ-009] says team-scoped edits do not retroactively affect in-progress games' portfolio state — that rule addresses heuristic config, not the operator mode. A strict reading of [06] leaves the mid-game behaviour of a default-operator-mode edit undefined.
**Question**: Does editing the default operator mode during a game affect the running game's current mode, the next game only, or neither (treated as a no-op until the next game starts)?
**Options**:
- A: Edit takes effect only on the next game's initial mode; running game is unaffected. (Current draft.)
- B: Edit takes effect immediately — the running game's current mode is reset to the new default.
- C: Edit is silently blocked while the team has a game in `playing` status.
**Informal spec reference**: §7.2.

**Decision**: Option A — all global defaults (including default operator mode) take effect only upon creating game-specific state at game launch. Running games are unaffected by edits to team-scoped defaults.
**Rationale**: This is already the semantics expressed by [06-REQ-009] for heuristic config, and the same principle applies uniformly to all team-scoped defaults including `global_centaur_params`. At game start, `initializeGameCentaurState` ([06-REQ-014], [06-REQ-040a]) copies team defaults into game-scoped state as a point-in-time snapshot. Once the game is live, the game-scoped `game_centaur_state` record is the live source of truth; the team defaults are irrelevant until the next game starts. This avoids the confusion of Option B (mid-game mode resets would be disruptive) and the unnecessary restriction of Option C (teams should be free to prepare their defaults for the next game while a current game is in progress).
**Affected requirements/design elements**: 08-REQ-022 amended with explicit language that all `global_centaur_params` edits affect the next game only. 06-REQ-009 confirmed as already correct (applies to all team-scoped defaults). 06-REQ-040a confirmed as already expressing the snapshot semantics correctly.

---

### 08-REVIEW-003: Game history visibility scope — **RESOLVED**

**Type**: Gap
**Phase**: Requirements
**Context**: 08-REQ-024 and 08-REQ-027 currently restrict the game history list to games the authenticated human participated in. Informal spec §7.3 says "completed games the logged-in user participated in", which supports this. But a coach or captain may want to review all of the team's past games regardless of personal participation. The informal spec does not contemplate this and the draft takes the narrow reading.
**Question**: Should the game history list show (a) only games the current human participated in, (b) all of the team's games, or (c) both with a toggle?
**Options**:
- A: Personal participation only. (Current draft.)
- B: All team games.
- C: Personal by default, toggle to show all.
**Informal spec reference**: §7.3.

**Decision**: A user sees a game in their history if they were either (a) a member of a participating team at the time of the game (per the game's participating-team snapshot of [05-REQ-029]) or (b) a current member of one of the participating teams now. Additionally, replay access for MVP is fully public: all replay data (including within-turn operational data of both teams) is publicly accessible to all authenticated users once a game has finished. The game history visibility rule only determines which games are proactively listed in a user's interface; if someone has a direct link to a game, any registered user can view the full replay. Private games are eliminated entirely for MVP.
**Rationale**: The expanded visibility rule (historical OR current membership) gives captains and coaches visibility into team games that occurred before they joined, which is important for team strategy review. Making replays fully public for MVP simplifies the access model dramatically — there is no privacy-gating complexity — and aligns with the open competitive spirit of the platform. The private-games concept added significant cross-module complexity for a feature that is not essential to MVP. It can be reintroduced in a future version if needed.
**Affected requirements/design elements**: 08-REQ-024 amended (historical or current team membership). 08-REQ-027 amended (removed negative restriction). 08-REQ-091 amended (Player Profile game history uses historical-or-current rule). 08-REQ-095 amended (Team Profile game history). 08-REQ-075d, 08-REQ-075e, 08-REQ-075f removed (private games eliminated). §8.15a removed. Private games removed across all modules: 02-REQ-066, 02-REQ-067 removed; 05-REQ-069, 05-REQ-070, 05-REQ-071, 05-REQ-072 removed; the original privacy-bypass 05-REQ-067 was removed (the 05-REQ-067 number slot has since been reused for the unrelated Coach Role); §5.12 removed (the §5.12 section number has since been reused for the unrelated Coach Role section); 05-REQ-023 game privacy row removed; 06 getCentaurActionLog privacy clause removed; 03-REQ-063 amended (privacy reference removed). GameConfig.gamePrivacy field removed.

---

### 08-REVIEW-004: Presence state store — **RESOLVED**

**Type**: Gap
**Phase**: Requirements
**Context**: 08-REQ-032 and 08-REQ-035 require a presence display of other connected team operators in the header. Neither [05] nor [06] defines a presence state field, and [06-REQ-018]'s selection record encodes only the current selector of a snake, not the set of connected operators who are unselected. A plausible implementation is that the Snek Centaur Server runtime itself holds presence state and serves it over its own subscription (outside Convex), but no module currently defines this contract. See 08-REQ-003 which already acknowledges the Snek Centaur Server as a source for in-memory bot-framework state the browser reads directly; presence likely rides the same channel. Requires explicit specification somewhere.
**Question**: Where does operator presence state live, and which module owns its specification?
**Options**:
- A: Snek Centaur Server in-memory state exposed to the browser via a server-hosted subscription. Requires [02] to acknowledge this subscription exists, and [08] to specify its shape.
- B: Convex ephemeral presence table owned by [06], with TTL-based cleanup.
- C: Derived from selection state only — "connected" means "has ever held a selection this session". Loses unselected-operator visibility.
**Informal spec reference**: §7.5 ("Connected operators shown as coloured dots with nicknames").

**Decision**: Roughly Option B — Convex-hosted presence solution. Operator presence state shall be managed through a Convex-hosted presence mechanism. The design phase should use the `@convex-dev/presence` library, which provides ephemeral presence state with heartbeat-based TTL cleanup natively within the Convex reactive query system.
**Rationale**: A Convex-hosted presence solution keeps operator presence within the same reactive data layer that the operator interface already subscribes to for all other state, avoiding the need for a separate subscription channel between the browser and the Snek Centaur Server. The `@convex-dev/presence` library provides exactly the semantics needed: ephemeral per-user presence with automatic cleanup when a client disconnects, delivered via Convex's reactive query system. This is simpler than Option A (which would require a separate real-time channel and server-side presence management) and richer than Option C (which loses visibility of unselected but connected operators).
**Affected requirements/design elements**: 08-REQ-032 amended to reference Convex-hosted presence. 08-REQ-035 amended to reference Convex-hosted presence. Design-phase note added: the implementation should use the `@convex-dev/presence` library for operator presence state.

---

### 08-REVIEW-005: Drive dropdown ordinal collisions — **RESOLVED**

**Type**: Gap
**Phase**: Requirements
**Context**: [06-REQ-007] says each Drive type has an ordinal dropdown position, and 08-REQ-052 orders the dropdown by that ordinal. Nothing in either module prevents two Drive types from having the same ordinal. In that case the ordering is underspecified; tiebreak behaviour could be alphabetic, insertion order, or stable-by-id. This matters because operators rely on the dropdown position as muscle-memory shorthand.
**Question**: What is the tiebreak when two Drive types have the same ordinal?
**Options**:
- A: Secondary sort by Drive type name (alphabetical). Stable and predictable.
- B: Secondary sort by Drive type registration order.
- C: Enforce uniqueness of ordinals in the heuristic config contract ([06-REQ-007]).
**Informal spec reference**: §7.6.

**Decision**: Replace the `dropdownOrder` ordinal system entirely with a pinned-heuristics list and lexicographic fallback. A `pinnedHeuristics` field (ordered array of heuristic IDs) is added to `global_centaur_params`. A `nickname` field is added to `heuristic_config`. The `dropdownOrder` field is removed from `heuristic_config`. Drive dropdown ordering is: pinned heuristics appear first in the order specified by the `pinnedHeuristics` array; remaining heuristics are ordered lexicographically by `nickname`, then by `heuristicId` as tiebreaker.
**Rationale**: The ordinal system was fragile — it required manual coordination of ordinal values across all Drive types, had no collision prevention, and was difficult to reorder (changing one Drive's position required updating others). The pinned-heuristics approach is more intuitive: the Captain pins the most-used Drives to the top in a specific order, and everything else falls into a stable alphabetic order by its human-readable nickname. The `nickname` field gives teams a way to assign meaningful short names to heuristics (which have machine-readable `heuristicId` values defined in source code). This eliminates the collision problem entirely and makes reordering a simple array manipulation on a single field.
**Affected requirements/design elements**: 06-REQ-007 amended (dropdownOrder replaced with nickname; ordering rule specified). 06-REQ-011 amended (pinnedHeuristics added to global_centaur_params). `heuristic_config` schema updated (dropdownOrder removed, nickname added). `global_centaur_params` schema updated (pinnedHeuristics added). 08-REQ-052 amended (new ordering scheme). 07-REQ-027, 07-REQ-028 updated (references to configured Drive ordering updated). Exported interface types updated.

---

### 08-REVIEW-006: Tab cycle deterministic tie-break in targeting — **RESOLVED**

**Type**: Gap
**Phase**: Requirements
**Context**: 08-REQ-054 orders Tab-cycled targeting candidates by A*-distance from the selected snake's head. Two candidate targets may be equidistant; the order they are visited by Tab is then undefined. As with the dropdown, this matters because operators come to rely on specific sequences during rapid play.
**Question**: What is the tiebreak when two candidate targets have equal A* distance?
**Options**:
- A: Secondary sort by target identity (snake id or cell coordinates in row-major order).
- B: Secondary sort by angle from the snake's head in a fixed rotation direction.
- C: Leave undefined; the operator must click directly if Tab produces ambiguity.
**Informal spec reference**: §7.6 ("in order of A* distance from the snake's head").

**Decision**: Option B with Option A as a tertiary fallback. The Tab cycle order shall be fully deterministic with three sort keys, in priority: (1) A*-distance from the selected snake's head, ascending; (2) clockwise angle in board coordinates from the snake's current head direction, starting at 0° (straight ahead) and increasing through 360°; (3) target identity — snake id ascending for snake targets, cell coordinates in row-major order (row then column ascending) for cell targets. The third key exists only to fully discharge the determinism obligation in pathological cases (e.g., two distinct candidates that share the same A*-distance and the same clockwise angle from the head — practically impossible for cell targets and only possible for snake targets if two candidate snakes' bodies somehow project onto exactly the same head-relative angle, which the head-A* distance key has already disambiguated whenever the candidate snakes occupy distinct cells).
**Rationale**: Clockwise-from-head is rotationally meaningful to the operator: the snake has an orientation, and "next clockwise" maps onto the operator's head-relative mental model of the board. A pure global identity sort (Option A) produces orientationally meaningless cycle orders that vary unpredictably as targets move around the board relative to the snake. Option C (leaving the tiebreak undefined) fails the determinism property that operator muscle memory depends on. The identity-based tertiary key keeps Option B fully deterministic without sacrificing its head-relative semantics in any realistic case.
**Affected requirements/design elements**: 08-REQ-054 amended to specify the three-key deterministic Tab cycle order.

---

### 08-REVIEW-007: Timekeeper affordance availability when no timekeeper is assigned — **RESOLVED**

**Type**: Gap
**Phase**: Requirements
**Context**: [05-REQ-011] says a team has at most one timekeeper at any time, implying the role may be absent. 08-REQ-065 and 08-REQ-067 say only the current timekeeper sees and can invoke the affordances. If no timekeeper is assigned, no member of the team can submit the turn in Centaur mode, and the game can only end by clock expiry. This is possibly intentional (a team that fails to assign a timekeeper is accepting that consequence) but is worth confirming.
**Question**: When a team has no timekeeper, who — if anyone — can invoke the mode toggle and turn-submit affordances?
**Options**:
- A: No-one. Centaur-mode games proceed only until clock expiry. (Current draft.)
- B: The captain acquires the affordances as a fallback.
- C: Any team member acquires the affordances as a fallback.
- D: The team is blocked from entering Centaur mode at all if no timekeeper is assigned.
**Informal spec reference**: §7.5 ("Timekeeper controls (visible only to the designated timekeeper)"); §8.2.

**Decision**: Moot — the timekeeper role has been eliminated per 05-REVIEW-014 resolution. All former timekeeper affordances (operator-mode toggle and turn-submit) are now Captain-only. The Captain is a structural role (`centaur_teams.captainUserId`) that always exists on every team, so the "no timekeeper assigned" edge case cannot arise. See amended §8.14 (now titled "Captain Controls") and 08-REQ-065 through 08-REQ-068.
**Rationale**: The timekeeper was eliminated as unnecessary MVP complexity. The Captain, being structurally required on every team, inherits the capabilities without any gap in coverage.
**Affected requirements/design elements**: 08-REQ-065, 08-REQ-066, 08-REQ-067, 08-REQ-068 amended (timekeeper → Captain). §8.14 retitled "Captain Controls". 02-REQ-043 amended (timekeeper assignment removed).

---

### 08-REVIEW-008: Replay-mode selection and Centaur state — **RESOLVED**

**Type**: Ambiguity
**Phase**: Requirements
**Context**: 08-REQ-074 asserts that replay-mode selection is a local UI concept that does not issue any Centaur state mutation. [06-REQ-018] defines the selection record as a per-(game, snake) Convex row. The replay viewer reads, but does not write, Centaur state. This is straightforward for the "invisible observer" reading but leaves one ambiguity: if two humans open replays of the same game simultaneously and each inspects a different snake, both can be inspecting different snakes without conflict (since neither writes). But if the team replay viewer in the future is extended to support shared replay sessions where multiple people see each other's positions, that extension would require either a new replay-selection record or a reuse of the selection record with a "replay selector" flag. The current draft does not contemplate shared replay sessions; this is a forward-compatibility concern.
**Question**: Confirm that replay-mode selection is purely client-local and does not require any additional Convex state.
**Options**:
- A: Purely client-local; no Convex state. (Current draft.)
- B: Add a replay-scoped selection record to [06] for future shared replay sessions.
**Informal spec reference**: §13.3 ("The replay viewer acts as an invisible additional observer").

**Decision**: Option A — non-mutating snake viewing (replay viewer per [08-REQ-074] and live-game coach mode per [08-REQ-052a]) is purely client-local; no Convex state is added and no SpacetimeDB write is issued. Even if shared replay sessions are added in the future, the exclusive-lock semantics of the existing selection mechanic ([06-REQ-018] through [06-REQ-024]) are inappropriate for shared replay gaze-tracking, because two replay viewers inspecting different snakes must not displace each other's view; that future extension would require a different (non-exclusive) state model and is out of scope here. Live-game coach inspection ([05-REQ-067], [08-REQ-052a]) needs the same affordance and the same semantics as replay inspection, since both are "invisible additional observer" use cases.

The decision additionally adopts the following terminology distinction across Module 08, applied uniformly to prose, requirement wording, identifier-style names, mutation names, Convex field names, and UI affordance labels:

- **selection** / **selector** / **selected snake** / `selectSnake` / `deselectSnake` / `operatorUserId` — retained for the existing exclusive-lock control affordance owned by [06]. A selection grants the holding operator the right to stage moves and toggle manual mode for the snake; only one operator at a time may hold a selection on any given snake; selections are persisted in Convex (`snake_operator_state.operatorUserId`) and produce per-operator coloured **selection shadows** on the board ([08-REQ-039]). All [06] identifiers and the existing [08] selection-acquisition prose ([08-REQ-039], [08-REQ-042], [08-REQ-043]) keep the "selection" name unchanged.
- **inspection** / **inspector** / **inspected snake** / `inspectSnake` / `clearInspection` / `inspectedSnakeId` — the new, non-mutating, purely client-local affordance by which a single viewer client (a replay viewer per [08-REQ-074] or a coach in live-game coach mode per [08-REQ-052a] / [08-REQ-052c]) chooses which snake's portfolio, stateMap, decision breakdown, worst-case world, and per-direction candidate highlights are displayed in their own UI. Inspection state is held in client-local UI state only; `inspectedSnakeId` is a client-local field, **never** a Convex field. Inspection never produces a selection shadow on the board, never issues any Convex or SpacetimeDB mutation, never displaces or interacts with any operator's selection, and is invisible to every other client.

Each viewer client may have at most one inspected snake at a time. Replay inspection and coach inspection share identical semantics; the only difference is the data source on which the inspection view is rendered (persisted replay + reconstructed action log for replay inspection; live SpacetimeDB and Convex subscriptions for coach inspection).

**Alternative names considered and rejected** (for traceability of the naming choice):
- **focus** / `focusedSnakeId` — overloaded with the established UI meaning of "input focus" (the focused element receiving keyboard events); also lacks a clean noun form for the holder ("focuser" reads awkwardly).
- **spotlight** / `spotlightedSnakeId` — connotes a presentational/broadcast metaphor (the snake is highlighted to others) rather than a private viewing decision; misleading for a per-client affordance.
- **gaze** / `gazedSnakeId` — matches the "gaze-tracking" framing in the original review prompt but is awkward as a verb in identifier names (`gazeSnake`, `gazeAtSnake`) and has no commonly understood adjective form.
- **preview** / `previewedSnakeId` — already used in this module to mean the worst-case world preview ([08-REQ-048]) and the board preview ([08-REQ-027i]); reusing it for snake viewing would collide with both.
- **view-selection** / `viewSelectedSnakeId` — preserves "selection" in the name and would defeat the entire purpose of the terminology distinction.

**Recommended term: "inspection"**, because (a) [08-REQ-074] already uses the phrase "select a snake for inspection", so the verb is already in this module's vocabulary; (b) "inspection" is semantically distinct from "selection" in everyday English (one inspects without taking ownership); (c) the noun/verb/adjective forms (inspect / inspector / inspected / inspection) are uniformly available and read naturally in identifier names, prose, and UI labels.

**Rationale**: Option A keeps [06]'s existing exclusive-lock selection semantics — and its Convex schema, mutations, and invariants — entirely unchanged for the existing operator-control affordance. The non-mutating viewing affordance for replay viewers and coaches is introduced without any Convex schema change or any new mutation; it is realised purely as client-local UI state in this module's web application. The "selection vs inspection" terminology distinction makes it lexically obvious at every use site which of the two affordances is intended, eliminating the structural ambiguity that motivated the original review.

**Affected requirements/design elements**: 08-REQ-074 reworded to use "inspection" terminology and to make explicit per-client / no-shadow / no-mutation semantics. 08-REQ-075 reworded to "inspection of any snake". 08-REQ-052c added (coach mode inspection affordance with semantics identical to replay inspection). 08-REQ-052d added *(negative)* (coach inspection must not use a gesture grammar confusable with operator selection). 08-REQ-071 reworded to refer to "snake inspection" within team-perspective replay rather than "snake selection". Module 06 §6.5 receives a single-sentence clarifying note that "selection" in that module refers exclusively to the exclusive-lock control affordance and that the separate non-mutating per-client **inspection** affordance is owned by [08] and adds no state to [06]; no [06] schema, mutation, identifier, or interface changes. [05-REQ-067] read scope is unchanged and is cross-referenced from the new coach-inspection requirement.

---

### 08-REVIEW-009: Scope of application customisation — **RESOLVED**

**Type**: Gap
**Phase**: Requirements
**Context**: [02-REQ-032(c)] (now removed) permitted "optional customization of the operator web application" as one of three extension points. Neither [02] nor [08]'s draft specified what "customisation" meant concretely: can a team replace entire pages? Inject arbitrary UI? Swap out the move interface? Override the board renderer? The boundary mattered because aggressive customisation could present the operator with affordances inconsistent with [06]'s invariants even though those invariants remained enforced server-side.
**Question**: What is the intended scope of customisation — theming only, component swapping, or full page replacement?
**Options**:
- A: Theming and layout tweaks only. Functional components are fixed.
- B: Component-level swapping with a stable component contract; functional boundaries preserved.
- C: Full page replacement; only the data-source abstraction (§8.12) and [06]'s function contracts are load-bearing.
**Informal spec reference**: §7 ("The Centaur Server library provides a reference implementation of the full web application; teams may customise the UI.").

**Decision**: Full source ownership via fork (supersedes options A/B/C). The operator web application is no longer an extension point of the Centaur Server library. Per [02-REQ-032a], teams obtain the operator app by forking the reference implementation repository and have complete freedom to modify any aspect of the UI — theming, component replacement, page restructuring, or full rewrites. The customisation scope is unbounded at the UI layer. Correctness is enforced externally by Convex function contracts ([06]) per [02-REQ-033], not by constraining what the UI may present. The data-source abstraction ([08-REQ-076]) exported by centaur-lib is the stable interface between the library and the operator app; teams' forks depend on this API surface for data access.
**Rationale**: Defining a bounded customisation interface within the library is unnecessary because the operator app is a separate forkable artifact, not a library extension point — the question of where to draw the customisation boundary dissolves once UI ownership transfers to the team's fork.
**Affected requirements/design elements**: [02-REQ-032(c)] removed; [02-REQ-032a] added; [08-REQ-076] data-source abstraction designated as the stable centaur-lib API surface.

---

### 08-REVIEW-010: Speed-control set in replay viewer — **RESOLVED**

**Type**: Proposed Addition
**Phase**: Requirements
**Context**: The informal spec §13.3 mentions that the team replay viewer has "play/pause, and speed controls", without enumerating a speed set. Informal spec §8.6 enumerates `{0.5×, 1×, 2×, 4×}` for the platform replay viewer. The draft pins `{0.5×, 1×, 2×, 4×}` for the board-level replay mode. If the team-perspective mode needs a different speed set (sub-turn scrubbing operates at finer granularity), it should be pinned now.
**Question**: Should the team-perspective replay mode use the same speed set as the board-level mode, and if not, what set?
**Options**:
- A: Leave to Phase 2 design; do not pin. (Current draft for team-perspective.)
- B: Pin `{0.5×, 1×, 2×, 4×}` for consistency.
- C: Team-perspective replay requires finer-grained control — different set.
**Informal spec reference**: §8.6; §13.3.

**Decision**: Supersede the single-speed-set framing entirely. The unified Replay Viewer's timeline control shall expose a **mode toggle** with two settings — **Per-Turn mode** and **Timeline mode** — each with its own scrubbing semantics, keyboard navigation, turn-marker rendering, and playback-speed set. The toggle is persistent across the viewer's lifetime within a single session and applies to both the board-level and team-perspective replay modes (08-REQ-069), so a single timeline control governs scrubbing for either replay mode.

- **Per-Turn mode**: scrubber shows turns as equidistant tick marks (one tick per turn); scrubbing snaps to the **end of each turn** (the centaur-state state-of-the-world that operators saw at the moment they were declaring submissions). No intra-turn positions are addressable in this mode. Playback advances one turn per tick at the configured rate. Speed-control set: **{0.25, 0.5, 1, 2, 4, 8} turns/second**.
- **Timeline mode**: scrubber's horizontal axis represents wall-clock time of the original game from game start (left) to game end (right). Turn boundaries are rendered along the timeline as **turn-marker glyphs** at the actual clock-time at which each turn was declared over (not equidistant — separation reflects the variable real wall-clock duration of each turn under the chess-clock mechanism). Scrubbing is continuous along clock time. Playback advances at a scalar multiple of real time. Speed-control set: **{0.25×, 0.5×, 1×, 2×, 4×, 8×}**.
- **Keyboard navigation in Timeline mode**: `Left`/`Right` (no modifier) seek ±1 second of clock time; `Shift+Left`/`Shift+Right` seek ±200 ms; `Ctrl+Left`/`Ctrl+Right` (use `Cmd` on macOS) snap to the previous/next turn-marker keyframe (the timeline-mode analogue of per-turn scrubbing without leaving timeline mode).
- **Keyboard navigation in Per-Turn mode**: `Left`/`Right` advance one turn backward/forward. Whether modifier keys are unbound or bound to a coarser/finer step (e.g., ±5 turns and ±1 turn respectively) is left as an explicit Phase-2 design decision.
- **Speed-control rendering**: the speed-control widget renders the current mode's unit in the label (e.g., "2 turns/s" vs "2× speed") so the operator is never ambiguous about what the multiplier means.
- **Mode toggle persistence**: the chosen mode and the chosen speed-within-mode are persisted in the viewer's client-local UI state and restored across navigation within the session. They are *not* persisted to Convex; this is purely a client preference.

**Rationale**: The prior draft pinned a single speed set without contemplating that the user's mental model differs between turn-level review (where "1×" means "one turn") and clock-time review (where "1×" means "real time"). Forcing both modes to share a single set conflates these. The toggle gives operators direct control over whether they are exploring strategic structure (per-turn) or timing dynamics (timeline). The variable inter-turn spacing in Timeline mode preserves the chess-clock signal that some turns burned more clock budget than others.

**Affected requirements/design elements**: 08-REQ-072 amended to incorporate the per-mode semantics and remove the prior `{0.5×, 1×, 2×, 4×}` pin; 08-REQ-072a added (mode toggle and persistence); 08-REQ-072b added (Per-Turn mode semantics and speeds); 08-REQ-072c added (Timeline mode semantics, turn-marker glyphs, and speeds); 08-REQ-072d added (keyboard navigation in both modes); 08-REQ-070a and 08-REQ-071 cross-link the unified control so both replay modes pick it up.

---

### 08-REVIEW-011: Interaction between automatic-mode timer and manual overrides mid-turn — **RESOLVED**

**Type**: Ambiguity
**Phase**: Requirements
**Context**: 08-REQ-062 (prior version) said the Automatic-mode timer proceeds independently of operator UI interactions. But [07-REQ-046] says manual-mode snakes are never auto-staged. If during an Automatic-mode turn an operator flips several snakes to manual mode and stages human moves for them, and then the Automatic timer fires, is the team's turn declared over with those human moves in place and the remaining automatic snakes' latest bot-staged moves? Informal spec §7.5 implies yes ("submitting all currently staged moves"). The requirements as drafted omitted this detail.
**Question**: On Automatic-mode timer expiry, does the turn-over declaration submit exactly the current staged moves for all owned snakes (mix of bot and human staging), or does it require all automatic-mode snakes to have a bot-staged move before firing?
**Options**:
- A: Declare turn over with whatever is currently staged. (Informal spec §7.5 reading.)
- B: Wait for [07]'s final-submission pass to flush all automatic-mode dirty flags before declaring.
- C: Combine: the timer expiry triggers [07]'s final pass synchronously, then declares.
**Informal spec reference**: §7.5 (header "Timekeeper controls — Submit shortcut key: immediately declares the team's turn over, submitting all currently staged moves").

**Decision**: Supersede the team-level operator-mode (Centaur / Automatic) model entirely with a **per-operator ready-state** model. The original ambiguity is dissolved at the source: there is no longer a team-level "Automatic-mode timer" whose expiry has to be reconciled with operator manual overrides. Instead:

- Each operator currently connected to the team's game session independently signals **ready / not-ready** for the current turn (per [08-REQ-061], persisted in [06]'s new `operator_ready_state` table per [06-REQ-040b]).
- The framework's automatic turn submission process is **gated** on **all currently-connected operators being simultaneously `ready`** (per [08-REQ-062]). The all-ready quorum is a *passive necessary precondition*, not a positive declaration — it simply permits the framework to finalise via `declare_turn_over` according to its own existing automatic submission rules ([07-REQ-044] / [07-REQ-045]), which are not restated here. The Captain's explicit turn-submit affordance ([08-REQ-065]) is an *independent override* path that bypasses this precondition entirely, immediately submitting whatever is currently staged and suppressing the framework's final flush per [07-REQ-045a]. Otherwise, the team's existing per-turn clock and time budget ([01-REQ-037], [01-REQ-038]) continue to govern the upper bound on turn duration.
- The framework's submission process — the team-level scheduled-pass cadence of [07-REQ-044] iterating over all dirty automatic-mode snakes, and the team-level final-flush deadline of [07-REQ-045] (`min(automaticTimeAllocationMs, remainingTimeBudget)`) — is unchanged in shape; manual-mode snakes remain excluded per [07-REQ-046]. The only substantive change to [07] is that the separate `turn0AutomaticTimeAllocationMs` carve-out is removed: turn 0 now uses the same `automaticTimeAllocationMs`, naturally bounded by the chess-clock's turn-0 budget via `remainingTimeBudget`.
- The `defaultOperatorMode` and `turn0AutomaticTimeAllocationMs` fields are removed from `global_centaur_params` and `game_centaur_state` (per [06-REQ-011] and [06-REQ-040a]). The remaining `automaticTimeAllocationMs` field is retained with its existing team-level turn-deadline semantics. The action-log event `mode_toggled` is removed and replaced by `operator_ready_toggled` (per [06-REQ-040b]).

**Rationale**: A single team-level mode forced an awkward question about whether a timer expiry should cooperate with mid-turn manual overrides. Per-operator ready-state matches the actual coordination problem teams face — every connected operator signals when they're done thinking — and elegantly accommodates mixed bot/manual staging because every operator simply waits to mark themselves `ready` until they're satisfied with the current state of *all* the snakes they care about. The Captain's turn-submit override remains as a tie-breaker for stuck or absent teammates. Coaches and admins, being read-only observers (per [08-REQ-052a]), have no ready-state and are never counted in the unanimity condition.

**Affected requirements/design elements**:
- **Module 08**: §8.12 retitled and rewritten ([08-REQ-061]–[08-REQ-064] rewritten; [08-REQ-064a] added for coach/admin no-ready-state); [08-REQ-020] / [08-REQ-022] amended (bot-parameters page no longer exposes operator-mode default or turn-0 time allocation); [08-REQ-032] amended (header presence display now shows per-operator ready-state instead of team-level operator-mode indicator); [08-REQ-034] removed; [08-REQ-052a] disabled-affordances list updated; [08-REQ-065] amended (Captain controls reduced to turn-submit only); [08-REQ-067] / [08-REQ-068] amended (per-operator ready-state is not Captain-only; `operator_ready_toggled` replaces `mode_toggled`); [08-REQ-071] amended (replay's read-only disabled-affordance list); [08-REQ-072] amended (replay reconstructs per-operator ready-state at scrubbed `t`); [08-REQ-086] / [08-REQ-096b] amended (mutating-affordance prohibitions reworded for ready-state).
- **Module 06**: [06-REQ-011] amended to drop `defaultOperatorMode` and `defaultTurn0AutomaticTimeAllocationMs` from `global_centaur_params`; [06-REQ-040a] amended to drop the corresponding game-scoped fields from `game_centaur_state`; [06-REQ-040b] added introducing the `operator_ready_state` table and the `setOperatorReady` mutation; [06-REQ-036] action-log event union amended (`mode_toggled` removed; `operator_ready_toggled` added); §2.1.1, §2.1.5, §2.2.6, §2.4 schemas/contracts updated; `toggleOperatorMode` (§2.2.3) removed and replaced by `setOperatorReady`; exported interfaces (§3.x) amended.
- **Module 07**: 07-REQ-045 amended (separate `turn0AutomaticTimeAllocationMs` carve-out removed; turn 0 uses the same `automaticTimeAllocationMs`, naturally bounded by `remainingTimeBudget` which already encompasses the chess-clock's turn-0 budget); 07-REQ-045a amended re: flush-suppression trigger; §2.13 deadline computation updated for the same turn-0 carve-out removal. 07-REQ-044 (team-level scheduled submission pass), 07-REQ-046 (manual-mode exclusion), and the team-level semantics of `automaticTimeAllocationMs` are unchanged. *(Subsequent corrections: (i) the original Affected entry incorrectly described 07-REQ-044 / 07-REQ-046 as amended and recharacterised `automaticTimeAllocationMs` as a "per-snake auto-submission timer that is no longer team-level" — none of that ever happened in [07]; corrected above. (ii) An interim draft of 07-REQ-045a generalised the flush-suppression trigger to "any turn-over declaration," covering both the Captain's manual button and the all-operators-ready quorum path; that generalisation was an overreach and has been reverted — flush suppression remains Captain-only. 08-REQ-062 and the §8.12 commentary above were also reframed to remove a related false claim that the bot framework's compute queue must be empty as part of the gating precondition.)*
- **Module 05**: [05-REQ-012] (operator-mode toggling) reworded to refer to per-operator ready-state toggling. The `defaultOperatorMode` and `defaultTurn0AutomaticTimeAllocationMs` rows mentioned by the cascade plan never existed in §5.5 / 05-REQ-023 (those fields live exclusively on Module 06's `global_centaur_params`); no parameter-table edits to §5.5 are required.
- **AGENTS.md**: Module 08 status line updated to record the resolution; cascade notes added for Modules 05, 06, 07.

---

### 08-REVIEW-012: Informal spec filename drift — **RESOLVED**

**Type**: Ambiguity
**Phase**: Requirements
**Context**: Consistent with 02-REVIEW-001, 06-REVIEW-007, 07-REVIEW-010. Requirements in this module were extracted from the informal spec now canonicalised at `informal-spec/team-snek-centaur-platform-spec.md`. Resolution is shared with the prior reviews.
**Question**: Confirm the current informal spec is canonical. See 02-REVIEW-001.
**Informal spec reference**: N/A (meta).

**Decision**: A — the current (unversioned) informal spec is canonical, consistent with the prior resolution of 02-REVIEW-001 (and the parallel resolutions of 06-REVIEW-007 and 07-REVIEW-010).
**Rationale**: Shared with 02-REVIEW-001. The earlier `SPEC-INSTRUCTIONS.md` filename drift has been resolved by renaming the informal spec to drop its version suffix; this module's requirements were extracted from that same content.
**Affected requirements/design elements**: None (meta-question).

---

### 08-REVIEW-013: Who marks a team ready — **RESOLVED**

**Type**: Gap (inherited from 05-REVIEW-007)
**Phase**: Requirements
**Context**: [08-REQ-027f] defers to [05] on which role within a team is permitted to mark the team ready. The informal spec §9.4 says "Captain or any operator", but 05-REVIEW-007 leaves the persistence and scope of readiness unresolved. Until 05-REVIEW-007 is resolved, the UI cannot fully specify its enablement logic.
**Question**: Which roles within an enrolled team may mark the team ready and unmark it?
**Options**:
- A: Captain only.
- B: Captain or any member with the Operator role.
- C: Any current team member regardless of role.
**Informal spec reference**: §9.4 step 3.

**Decision**: A — Captain only.
**Rationale**: This aligns the operator UI's enablement logic with the upstream Captain-only ready-check authorization that [05] already pins via [05-REQ-031] (after the 05-REVIEW-007 resolution). It also preserves the principle that team-level commitments (like declaring readiness for a game) are the Captain's prerogative, consistent with the broader Captain-only scoping established by 08-REVIEW-001 for team-scoped configuration.
**Affected requirements/design elements**: 08-REQ-027f amended (deferral text removed; Captain-only enablement made explicit; non-Captain members see a read-only readiness indicator).

---

### 08-REVIEW-014: Board preview generation locality — **RESOLVED**

**Type**: Ambiguity
**Phase**: Requirements
**Context**: [08-REQ-027i] describes a miniature board preview that regenerates as the administrative actor edits room configuration parameters. Two questions are underspecified: (a) is the preview generated client-side by running a JavaScript port of the board-construction algorithm owned by [01], or server-side by Convex calling into a shared engine codebase per [02-REQ-035]; (b) does the preview need to be deterministic with a seed such that locking one in ([08-REQ-027j]) reliably reproduces the same layout at game start?
**Question**: Where is the preview generated, and is determinism via seed required for lock-in to work?
**Options**:
- A: Client-side generation using a shared algorithm port; lock-in persists the seed only; [04] honours the seed at game init.
- B: Server-side generation via a Convex action; lock-in persists the server-generated layout directly; [04] honours the layout as a supplied parameter rather than regenerating from a seed.
- C: Client-side generation without lock-in guarantee (the preview is decorative only); lock-in is removed as a feature.
**Informal spec reference**: §8.4 (Room Lobby, Board preview).

**Decision**: Custom — the Convex preview mutation defined by [05-REQ-032b] is the sole authority for generating a board from input parameters. The preview runs `generateBoardAndInitialState()` from the shared engine codebase ([02-REQ-035]) inside a Convex mutation on each parameter edit and is delivered to the web client reactively via Convex's reactive query model. SpacetimeDB never generates a starting board — its `initialize_game` payload always carries the complete pre-computed initial game state plus dynamic gameplay parameters; board-generation parameters are consumed entirely within Convex. The application performs no client-side board generation. This simply ratifies the already-pinned upstream architecture of [05-REQ-022] and [05-REQ-032b] (the "config-on-game" architecture established by 05-REVIEW-008 and the board-generation locality established by Task #8).
**Rationale**: A single source of truth for board generation eliminates client/server determinism concerns, eliminates any need for a JavaScript port of the construction algorithm, and matches the upstream architecture already pinned by [05]. Determinism via persisted seed is therefore moot — the preview is itself the persisted starting state, regenerated on demand by Convex.
**Affected requirements/design elements**: 08-REQ-027i amended (Convex preview mutation is the generator; no client-side board generation; preview delivered reactively). Module-08 sweep performed: only 08-REQ-027i / 027j / 027k mention board preview generation, and they are corrected together with 08-REVIEW-015. Cross-reference: [05-REQ-022] and [05-REQ-032b] are unchanged by this resolution — it ratifies them.

---

### 08-REVIEW-015: Where a locked-in board preview is persisted — **RESOLVED**

**Type**: Gap
**Phase**: Requirements
**Context**: [08-REQ-027j] says lock-in of a board preview must cause the subsequent game-start orchestration of [05-REQ-032] to seed the game with the locked-in layout. But [05] does not currently have a requirement acknowledging this — [05-REQ-024] talks about parameter snapshots, not generated-content snapshots. A locked-in preview is neither a parameter value nor a derived-from-parameters quantity; it is a concrete board layout that needs to live somewhere in the Convex schema and be plumbed through to [04]'s `initialize_game` reducer.
**Question**: Does the locked-in preview belong in the room record, the next-game's record, or in a separate preview table? And does it extend [05-REQ-032]'s required init payload?
**Options**:
- A: Add a field on the room record holding the currently-locked preview, consumed and cleared at next game-start.
- B: Create the game record eagerly at lock-in time and attach the preview to it.
- C: The locked preview is not persisted at all; it is re-rendered at game-start from a persisted seed and the current parameters.
**Informal spec reference**: §8.4 (Room Lobby, Board preview lock-in); §9.4 (Game Lifecycle).

**Decision**: Custom (essentially Option A scoped to the not-yet-started game record, not the room record). The starting game state always lives on the not-yet-started game record's configuration document, alongside its other configuration parameters. A separate `boardPreviewLocked: boolean` flag on the same game record indicates whether locking is in effect. Every preview generation by [05-REQ-032b] writes the resulting starting state onto the game record, regardless of lock-in status; the flag governs only whether [05-REQ-032] step 2 reuses the persisted state (true) or regenerates from a fresh seed at game-launch initiation (false). When unlocked, the regenerated starting state is not displayed to any participant via the configuration UI — it is only seen by operators after it reaches their Centaur interface via the SpacetimeDB subscription. This extends to the starting game state itself the principle (already pinned by 05-REVIEW-008 and materialised by [05-REQ-022] / [05-REQ-032b]) that all configuration parameters are configured on a not-yet-started game record, never on the room record.
**Rationale**: Keeps configuration on a single document (the game), eliminates a separate preview table, and reduces "lock in" to a single boolean affecting one well-defined behaviour at game-launch initiation. Persisting on every regeneration (rather than only on lock-in) keeps the data shape uniform and makes the unlocked-but-not-yet-started case trivially reactive in the UI.
**Affected requirements/design elements**: 08-REQ-027j amended (explicit semantics of `boardPreviewLocked`; persistence on every regeneration; unlocked regeneration is not surfaced to configuration-mode UI). Cascade to [05]: [05-REQ-032b] amended (every preview generation persists onto the game record; `boardPreviewLocked` flag governs reuse). [05-REQ-032] step 2 amended (conditional on `boardPreviewLocked`, not on "if a preview was locked in").

---

### 08-REVIEW-016: Public vs authenticated-only visibility of profiles and leaderboard — **RESOLVED**

**Type**: Ambiguity
**Phase**: Requirements
**Context**: The informal spec §8.7 and §8.8 describe Player Profile and Team Profile pages as "public" in one place and as accessible to "any authenticated user" in others. The current draft assumes authentication is required for all platform views ([08-REQ-006]) but this is in tension with the "public" framing. A related question is whether email addresses on Player Profiles should be visible to all authenticated users or only to the profile owner and their team-mates.
**Question**: Are team and player profiles public (accessible without authentication) or authenticated-only? And what is the visibility scope of email addresses on Player Profiles?
**Options**:
- A: Authentication required for all views (current draft of 08-REQ-006). Emails visible to all authenticated users.
- B: Team and player profile pages are public and indexable. Emails hidden except on the user's own profile.
- C: Team profile public, player profile authenticated-only. Emails hidden everywhere except self-view.
**Informal spec reference**: §8.7, §8.8.

**Decision**: A, with one clarification — emails are never exposed to any user query. Authentication is required for all platform views per [08-REQ-006]. User identity surfaced to other authenticated users is the OAuth-provided display name only (per [03] §3.14). Email addresses are stored in Convex (necessary for OAuth identity matching and admin recovery flows) but are not exposed in any user-facing query: not on Player Profile (including the user's own self-view), not on Team Profile, not on team-member listings, not on game-history attributions, and not on leaderboards.
**Rationale**: Minimises PII surface area while preserving the platform's auth-required posture. The user's email is owned by the OAuth provider; the application has no authoritative reason to display it back to the user, and exposing it to other authenticated users (even within a team) is an unnecessary leak. The "public" framing in the informal spec conflates "accessible to any user of the platform" with "accessible to anyone on the internet"; this resolution pins the former.
**Affected requirements/design elements**: 08-REQ-090 amended (deferral removed; explicit auth-only). 08-REQ-091 amended (email removed from Player Profile display). 08-REQ-094 amended (deferral removed; explicit auth-only). 08-REQ-094f amended (deferral removed). 08-REQ-091a added as a new module-08-owned negative requirement: "No application view shall expose any user's email address to any other user, nor to the user themselves" — this constrains [05]'s query surface (no [05] user-scoped query may include email in its returned shape). Downstream impact (recorded as a constraint, not a [05] requirement amendment in this task): [05]'s query layer must enforce 08-REQ-091a; this constraint should be honoured by [05] Phase 2 design and any future [05] query additions.

---

### 08-REVIEW-017: Deleted teams in leaderboards — **RESOLVED**

**Type**: Gap
**Phase**: Requirements
**Context**: [05-REQ-015a] permits Centaur Team deletion while preserving historical participating-team snapshots. [08-REQ-094e] currently says the leaderboard continues to resolve historical teams via snapshots, implying a deleted team could still appear in leaderboards under its historical identity. This may be undesirable — a team might be deleted because it was created in error, was used for spam, or belonged to a departed user — and the leaderboard may want to hide it. On the other hand, hiding it rewrites historical outcomes.
**Question**: Should deleted Centaur Teams continue to appear in the global leaderboard?
**Options**:
- A: Yes — deleted teams continue to appear under their historical identity; deletion is purely a live-state operation. (Current draft.)
- B: No — deleted teams are excluded from leaderboard listings but remain in per-game history where they participated.
- C: Configurable per leaderboard view with a "include deleted teams" toggle.
**Informal spec reference**: N/A (gap). See also 05-REVIEW-011.

**Decision**: The question is moot — Centaur Teams cannot be deleted. Per [05-REQ-015a] (resolved by 05-REVIEW-011), Centaur Teams are archive-only: archiving hides the team from default listings and prevents new-game enrolment but preserves all live and historical state, and historical game records continue to resolve the team's historical identity for attribution. The leaderboard, which already uses participating-team snapshots per [08-REQ-094e], therefore continues to display the team under its archived identity. Archived teams shall continue to appear in the default leaderboard view, consistent with the principle that archiving is a live-state hide-from-listings action and not a historical-state rewrite (the same pattern as room archiving per [05-REQ-021a]). A future enhancement may add an opt-out filter for archived teams, but it is not required.
**Rationale**: Deletion is not a thing in this platform; the original premise of the question is invalidated by the upstream resolution (05-REVIEW-011). Hiding archived teams from the leaderboard would rewrite historical outcomes; preserving them costs nothing and keeps competitive history intact.
**Affected requirements/design elements**: 08-REQ-094e amended ("deleted" → "archived"; deferral removed; positive statement that archived teams remain in default leaderboard view). 08-REQ-093, 08-REQ-097, 08-REQ-103 incidentally amended in the same sweep ("deleted" → "archived") to enforce platform-wide archive-only terminology. References [05-REQ-015a] / 05-REVIEW-011 as the upstream resolution.

---

### 08-REVIEW-018: Live spectating when invisibility is active — **RESOLVED**

**Type**: Ambiguity
**Phase**: Requirements
**Context**: [08-REQ-083] says the spectator view honours invisibility filtering per [04-REQ-047] — i.e., invisible snakes simply are not delivered to spectator subscriptions. But the spectator is nonetheless a third-party observer whose scoreboard ([08-REQ-084]) aggregates alive-snake lengths per team. If a team has an invisible snake, the spectator's scoreboard either (a) reflects the reduced visible length (misleading — the snake is still alive), (b) reflects the true aggregate (requires server-side calculation with team privilege, violating the spectator-view data model), or (c) omits the invisible snake from the count while marking the score as "partial." This tension is not addressed by the informal spec.
**Question**: How does the spectator scoreboard handle invisible snakes?
**Options**:
- A: The scoreboard shows only what the spectator subscription delivers; invisible snakes are simply not counted. The spectator experience is intentionally lossy.
- B: The scoreboard shows true aggregates computed server-side using a privileged aggregate query that bypasses per-snake visibility; only aggregates are disclosed, not per-snake state.
- C: The scoreboard distinguishes "visible length" from "total length, some hidden," alerting the spectator that hidden snakes exist on that team.
**Informal spec reference**: §8.5 (Live Spectating); §4.3 (Invisibility potion semantics).

**Decision**: Custom (Option B generalised). Clients are dumb readers of state shared by SpacetimeDB views; they do not compute scores from raw snake data. The spectator scoreboard shall be backed by a dedicated SpacetimeDB scoreboard view that publishes per-team aggregate scores (computed server-side over the true alive-snake set, including invisible snakes) and exposes only the aggregates — never per-snake state for invisible snakes. This is generalised beyond the scoreboard: the broader principle is that client UIs render state delivered by SpacetimeDB views and do not reconstruct game-mechanics quantities (score, length aggregates, win conditions) from raw subscription data they may have an incomplete view of.
**Rationale**: A single server-side authority over score eliminates client/server divergence, eliminates the invisibility leak that would arise from clients aggregating only visible snakes, and aligns with [04-REQ-047]'s server-side filter posture. The per-snake invisibility filter ([08-REQ-083]) remains in force; the scoreboard view is the only server-side aggregate channel and per-snake state is still filtered by visibility.
**Affected requirements/design elements**: 08-REQ-084 amended (scoreboard sourced from a dedicated SpacetimeDB scoreboard view, not client-aggregated; "proxy for team score pending 05-REVIEW-006" parenthetical dropped — score semantics are owned upstream and the client just renders them). 08-REQ-084b added as a negative requirement: the application shall not compute team-level aggregate quantities by aggregating raw per-snake subscription data on the client. 08-REQ-083 unchanged. Downstream impact (recorded as a constraint, not a [04] requirement amendment in this task): [04] Phase 2 design (already drafted, §2.9 / §2.12) must add a scoreboard view to its visibility-filtering / view design; concretely, a `scoreboard_view` per game is needed exposing `(teamId, teamScore, aliveSnakeCount, aggregateLength)` computed over the true snake set, subscribable by spectator and operator clients alike. This is recorded here as a downstream impact for [04] Phase 2 design to address; an accompanying open `04-REVIEW-020` item is filed (see [04]'s REVIEW Items section) so the work is not lost.

---

### 08-REVIEW-019: Timeline scrubber data delivery for long games — **RESOLVED**

**Type**: Gap
**Phase**: Requirements
**Context**: [08-REQ-087] asserts the spectator timeline scrubber leverages [04-REQ-057] historical reconstruction. [04-REQ-054]'s subscription patterns mention that a client joining mid-game can subscribe to full history. For short games this is fine, but for long games (tournament rounds, extended max-turn games) the initial delivery could be sizable. The question is whether the UI must demand full history up-front on entry to the spectator view or can lazily fetch historical slices as the user scrubs.
**Question**: Does live spectating entry require an up-front full-history subscription, or does the UI fetch historical slices on demand?
**Options**:
- A: Up-front full subscription — simplest client code, possibly slow entry on long games.
- B: Live-only subscription on entry; lazy-fetch historical slices via query only when the user scrubs backward.
- C: Hybrid — subscribe to current turn + a configurable window (e.g., last 20 turns) on entry; lazy-fetch beyond that.
**Informal spec reference**: §8.5 (Live Spectating timeline scrubber); §10 (Client Query Patterns).

**Decision**: A — up-front full-history subscription on entry to the spectator view. Games are bounded to at most a few hundred turns and a few seconds of loading is acceptable for the spectator entry experience (worst case).
**Rationale**: Simplest client implementation, no lazy-fetch state machine, no fallback paths to maintain; the worst-case latency is acceptable per the explicit user tolerance. Lazy fetching would add a moving-window state machine and visibly stutter when the user scrubs to a turn outside the prefetched window — a worse UX in exchange for a small entry-time saving on a small population of unusually long games.
**Affected requirements/design elements**: 08-REQ-087 amended (positive statement that the UI subscribes to the game's full historical state up-front on entry, per [04-REQ-054]'s mid-game-join subscription pattern, accepting bounded entry latency proportional to game length).

---

### 08-REVIEW-020: Game-in-progress discoverability on the home view — **RESOLVED**

**Type**: Ambiguity
**Phase**: Requirements
**Context**: [08-REQ-010a] says the home view lists "games currently in progress in which any of the user's Centaur Teams are participating." But the spectator affordance is available to *any* authenticated user — users may want to discover interesting games in progress even in rooms they have no team affiliation with. The informal spec §8.1 describes the home view narrowly around memberships and recents, leaving general discovery to the Room Browser. Whether a dedicated "live games" discovery surface is needed is not answered.
**Question**: Should the home view or the Room Browser expose a dedicated listing of all games currently in progress regardless of team affiliation?
**Options**:
- A: Only games involving the user's teams on the home view; no platform-wide live-games listing. (Current draft.)
- B: Add a "live games" section to the home view showing all platform-wide games in progress.
- C: Add a filter to the Room Browser for "rooms with a game in progress."
**Informal spec reference**: §8.1, §8.3.

**Decision**: A — only games involving the user's teams are listed on the home view; no platform-wide live-games discovery surface is added in this revision.
**Rationale**: Matches the current draft and the informal spec §8.1's narrow framing of the home view around memberships and recents; general discovery remains the Room Browser's responsibility (already accessible from the global navigation per [08-REQ-010]). A platform-wide live-games surface can be added later if user behaviour warrants it.
**Affected requirements/design elements**: None — [08-REQ-010a] is left as-is in substance. No "see 08-REVIEW-020" deferral text exists in any requirement (the deferral was confined to the REVIEW item itself), so no body-text amendment is required.

---

### 08-REVIEW-021: Heuristic registry drift between server and team configuration — **RESOLVED**

**Type**: Gap
**Phase**: Requirements
**Context**: [06-REQ-005] states that heuristic defaults are per-CentaurTeam and that when a team replaces its Centaur Server, the new server inherits the existing heuristic defaults. [08-REQ-058] says the application shall not expose Drives whose types are not registered in the team's heuristic default configuration. However, there is no specification for what happens when the set of heuristic IDs registered in a team's Centaur Server source code diverges from the set of heuristic IDs in the team's `heuristic_config` table. This drift can occur in two directions: (a) the new server introduces heuristic IDs that have no `heuristic_config` entry (new Drives/Preferences added in code), and (b) the team's `heuristic_config` contains entries for heuristic IDs that the new server does not register (stale entries from a previous server). The original draft said stale entries are "ignored at runtime and may be cleaned up by the team" (06-REVIEW-001 resolution) but did not specify how the UI handles this — in particular, whether stale Drives appear in the dropdown, whether new (unconfigured) Drives are accessible, and whether the heuristic configuration page surfaces the mismatch.
**Question**: How should the UI handle heuristic ID mismatches between the running server's registered heuristic set and the team's persisted `heuristic_config`?

**Decision**: The Snek Centaur Server's bot framework ([07] §2.3) defines a build-time-shared TypeScript module `HEURISTIC_REGISTRY: ReadonlyArray<HeuristicRegistration>` that is imported by both the framework runtime and the SvelteKit frontend (this module — they share a workspace package and compile against the same source file at build time). Drift between "what the server can simulate" and "what the UI can render" is therefore structurally impossible within one build artifact.

The frontend's behaviour:

1. **In-game Drive dropdown** ([08-REQ-052]): sources its options from the **intersection** `heuristic_config ∩ HEURISTIC_REGISTRY` filtered to `heuristicType = "drive"`, ordered per [06-REQ-007]'s pinned-then-lexicographic scheme. Drives present in `heuristic_config` but absent from the registry are hidden from the dropdown (stale). Drives present in the registry but absent from `heuristic_config` are also hidden from the dropdown (the lazy-insert below ensures this state does not persist past a Captain visit to the global params page).

2. **Lazy-insert on global centaur params page visit** ([08-REQ-014]): when the Captain visits the global centaur params page, the page calls a new `insertMissingHeuristicConfig({ centaurTeamId, registrations })` mutation on Module 06 (added per [07] §2.19) under the Captain's Convex auth credential. The mutation is **insert-only and never overwrites**: for each registration whose `heuristicId` is not already in the team's `heuristic_config`, it inserts a row using the registry's `defaultWeight`, `activeByDefault`, and `nickname` as initial values; for IDs already present, it does nothing. Once written, `heuristic_config.weight`/`activeByDefault`/`nickname` override the source-code `defaultWeight`/`activeByDefault`/`nickname` (Convex is authoritative).

3. **Stale-entry display on global centaur params page** ([08-REQ-014]): heuristic IDs present in `heuristic_config` but absent from the current registry are visually distinguished as "stale" (e.g., greyed out with a "no longer registered by this server" annotation) and offered a delete affordance that calls `deleteHeuristicConfig`. They are **not** surfaced in the in-game Drive dropdown, only on the global centaur params page where the Captain can see and clean them up.

4. **No framework writes to `heuristic_config`**: the bot framework itself never invokes `insertMissingHeuristicConfig` or any other `heuristic_config` mutation ([07-REQ-018]). The lazy-insert is invoked from this module's frontend under the Captain's credential because the Captain is the trust anchor for changes to team configuration ([06] §2.6; 08-REVIEW-001).

**Rationale**: A build-time-shared TypeScript module eliminates runtime drift at the build-artifact level, requires no new wire protocol, and propagates literal heuristic-ID types end-to-end into the frontend's component props. The lazy-insert pattern (rather than automatic background sync) keeps the Captain in control of when registry defaults become persisted configuration: the Captain's act of visiting the global centaur params page constitutes the consent. Insert-only-never-overwrites preserves Captain-edited values on subsequent registry expansions.

**Affected requirements/design elements**: [07] §2.3, §2.18, §2.19, §3.1, §3.7 added in [07] Phase 2. [06] amended to add the `insertMissingHeuristicConfig` mutation per [07] §2.19. This module's frontend (Phase 2) imports `HEURISTIC_REGISTRY` from the workspace package and wires the lazy-insert call into the global centaur params page load lifecycle.

**Informal spec reference**: §7.1 (heuristic configuration); §7.6 (Drive dropdown).

---

### 08-REVIEW-022: Centaur-lib package name inconsistency between [02] and [08]
**Type**: Ambiguity
**Phase**: Design
**Context**: 08-REQ-076 names the published library package `@team-snek/centaur-lib`. [02] §2.13 / §2.16a (and [02-REQ-030] / [02-REQ-032a]) name the same artifact `@snek-centaur/server-lib`. Both names refer to the same artifact — the Snek Centaur Server library that exports the data-source abstraction (§3.2), the per-operator stable-colour function (§3.3), the presence channel shape (§3.4), the invitation endpoint contract (§3.1), and re-exports `startGameSession` from [07]. Module 08's Phase 2 design canonicalises on [02]'s name (`@snek-centaur/server-lib`) for consistency with the existing Phase-2-completed architectural module that pinned the package graph; the per-task instructions explicitly prohibit editing [02] from this module's Phase 2 task and direct that any cross-module cascade be filed as a REVIEW item rather than silently resolved.
**Question**: Which of the two names is canonical going forward?
**Options**:
- A: Canonicalise on `@snek-centaur/server-lib` (matches [02], the platform-architecture module that owns package-graph decisions). Amend 08-REQ-076 to use this name.
- B: Canonicalise on `@team-snek/centaur-lib` (matches 08-REQ-076 as currently written, plus aligns the prefix with `@team-snek/heuristics` per [02] §2.16a / [07-REVIEW-015]). Amend [02] §2.13 / §2.16a / [02-REQ-030] / [02-REQ-032a] to use this name.
- C: Adopt a third name (e.g., `@team-snek/server-lib`) that aligns the namespace with `@team-snek/heuristics` and `@team-snek/bot-framework` while dropping the `centaur-lib` ambiguity. Amend both [02] and 08-REQ-076.
**Informal spec reference**: §2 (architectural overview, package-graph language was not formalised in the informal spec).

---

### 08-REVIEW-023: Worst-case world annotations data substrate excised upstream
**Type**: Gap
**Phase**: Design
**Context**: 08-REQ-049 specifies that annotations computed against the worst-case world (Voronoi-style territory overlay and any other team-configured annotations) shall be rendered against the worst-case world rather than the current board, sourced from the `annotations` field of the computed display state per [06-REQ-026]. However, the [07] Phase 2 resolution of 07-REVIEW-014 (and its two follow-up resolutions) excised the `WorldAnnotations` per-direction record from `SnakeBotStateSnapshot.worstCaseWorlds` and dropped the corresponding `snake_bot_state.annotations` column from [06]'s schema; the [07] §3.4 exported snapshot shape carries no annotations payload. The 07-REVIEW-014 resolution explicitly defers a replacement annotations design to "[08] Phase 2 once the operator UI's annotation needs are concrete" ([07] §2.11 narrative; [07] §3.6 removal note). This Phase 2 design pass for [08] does not have enough concrete annotation requirements (beyond the single Voronoi-style example named in 08-REQ-049) to design a replacement substrate without speculation, so layer 6 of the board renderer (§2.7) and the worst-case world preview (§2.9) currently render the simulated `state` only and surface no per-direction annotations.
**Question**: How should the worst-case-world annotations substrate be reintroduced to satisfy 08-REQ-049, given that [07] §3.4 no longer publishes one and the open-shape `WorldAnnotations` design was rejected?
**Options**:
- A: Reintroduce a closed-set typed annotations payload on `SnakeBotStateSnapshot.worstCaseWorlds` enumerating exactly the operator-UI-visible annotations (e.g., `{ voronoiTerritory?: TerritoryMap }`); cascade into [07] §3.4, [06] §2.1.3, and [04] (no impact). Closed set keeps the wire shape stable and forces additions to be explicit cross-module amendments.
- B: Compute annotations client-side in [08] from the published `SimulatedWorldSnapshot.state` using a small set of [08]-owned analysers (e.g., a Voronoi BFS over the simulated `GameState`). No upstream cascade, but [08] does work the framework previously did.
- C: Drop annotations entirely from the MVP UI (treat 08-REQ-049 as a documented deferral with no design surface); revisit when concrete annotation needs are surfaced by users.
**Informal spec reference**: §7.5 (worst-case world annotations); §7.6 (Voronoi territory display).
