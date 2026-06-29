// set the focused window's split direction from its live geometry.
// re-checks on focus, new, move, floating and fullscreen: a reshape with no refocus still updates.
// a pure tiled resize fires no ipc event, it self-corrects on the next focus or move.

use swayipc::{
    Connection, Event, EventType, Fallible, Node, NodeLayout, NodeType, WindowChange,
};

fn main() -> Fallible<()> {
    let events = Connection::new()?.subscribe(&[EventType::Window, EventType::Workspace])?;
    let mut sway = Connection::new()?;

    for event in events {
        let recheck = match event? {
            Event::Window(w) => matches!(
                w.change,
                WindowChange::New
                    | WindowChange::Focus
                    | WindowChange::Move
                    | WindowChange::Floating
                    | WindowChange::FullscreenMode
            ),
            Event::Workspace(_) => true,
            _ => false,
        };
        if !recheck {
            continue;
        }

        let tree = sway.get_tree()?;
        let Some((node, parent)) = focused(&tree, NodeLayout::None) else {
            continue;
        };

        // skip tabbed/stacked, floating and fullscreen, act only on leaf windows
        if matches!(parent, NodeLayout::Tabbed | NodeLayout::Stacked)
            || node.node_type == NodeType::FloatingCon
            || node.fullscreen_mode.unwrap_or(0) != 0
            || !node.nodes.is_empty()
        {
            continue;
        }

        // split along the long axis so the next window squares the pair up
        let cmd = if node.rect.height > node.rect.width {
            "split vertical"
        } else {
            "split horizontal"
        };
        sway.run_command(cmd)?;
    }
    Ok(())
}

// depth-first hunt for the focused leaf, passing each parent's layout to the caller
fn focused(node: &Node, parent_layout: NodeLayout) -> Option<(&Node, NodeLayout)> {
    if node.focused {
        return Some((node, parent_layout));
    }
    node.nodes
        .iter()
        .chain(node.floating_nodes.iter())
        .find_map(|child| focused(child, node.layout))
}
