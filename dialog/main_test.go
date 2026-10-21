package main

import (
	"testing"

	tea "github.com/charmbracelet/bubbletea"
)

// key builds the KeyMsg the real terminal delivers for a key name.
func key(name string) tea.KeyMsg {
	return tea.KeyMsg{Type: tea.KeyRunes, Runes: []rune(name)}
}

func testModel() model {
	return newModel([]group{{
		name: "DAW",
		items: []*item{
			{name: "Reaper", pkg: "reaper"},
			{name: "Bitwig Studio", pkg: "bitwig-studio"},
		},
	}})
}

// The 2026-10-21 laptop install: apps were ticked, enter was pressed, nothing
// installed and nothing explained why. Enter must finish the picker whenever
// something is ticked, from any row (the Done row is no longer a gate).
func TestEnterInstallsTickedAppsFromAnyRow(t *testing.T) {
	m := testModel()
	m.flat[0].checked = true
	m.cursor = 1 // deliberately not on the Done row

	updated, _ := m.Update(key("enter"))
	got := updated.(model)

	if !got.done {
		t.Fatal("enter with a ticked app must finish the picker")
	}
	if got.cancel {
		t.Fatal("enter must not cancel")
	}
}

func TestEnterWithNothingSelectedExplainsInsteadOfQuitting(t *testing.T) {
	m := testModel()

	updated, _ := m.Update(key("enter"))
	got := updated.(model)

	if got.done || got.cancel {
		t.Fatal("enter with no picks must leave the picker open")
	}
	if got.note == "" {
		t.Fatal("enter with no picks must set a visible note")
	}
}

func TestSpaceTicksAppAndEnterInstalls(t *testing.T) {
	m := testModel()

	updated, _ := m.Update(key(" "))
	got := updated.(model)
	if !got.flat[0].checked {
		t.Fatal("space must tick the app under the cursor")
	}

	updated, _ = got.Update(key("enter"))
	if !updated.(model).done {
		t.Fatal("enter after ticking must finish")
	}
}

func TestEscStillCancels(t *testing.T) {
	m := testModel()
	m.flat[0].checked = true

	updated, _ := m.Update(key("esc"))
	got := updated.(model)

	if !got.cancel {
		t.Fatal("esc must cancel, even with apps ticked")
	}
	if got.done {
		t.Fatal("esc must not install")
	}
}

// The Done row's checkbox is a count indicator, not an arming step.
func TestDoneRowReflectsSelection(t *testing.T) {
	m := testModel()
	if m.selectedCount() != 0 {
		t.Fatalf("fresh model should have no picks, got %d", m.selectedCount())
	}
	m.flat[1].checked = true
	if m.selectedCount() != 1 {
		t.Fatalf("selectedCount = %d, want 1", m.selectedCount())
	}
}
