import assert from "node:assert/strict";
import { test } from "node:test";
import * as c from "../js-out/calcit.core.mjs";
import { store, normalize_op, decode_store } from "../js-out/app.schema.mjs";
import { updater } from "../js-out/app.updater.mjs";

// Phlox reads the browser user agent at import time; these tests do not render PIXI.
const previousWindow = globalThis.window;
globalThis.window = { navigator: { userAgent: "node" } };
const { run_command } = await import("../js-out/app.comp.container.mjs");
if (previousWindow === undefined) delete globalThis.window;
else globalThis.window = previousWindow;

const t = c.init_tags(["slides", "slide-key", "logs", "op", "snapshot", "type", "position", "sizes", "radius", "main-hint", "secondary-hint", "states", "spin", "data", "pointer", "spin-pos", "hydrate-storage"]);
const read = (value, key) => c.option_$o_unwrap(c.get(value, t[key]));
const step = (value, message) => updater(value, normalize_op(message), "fixture", 0);
const send = (value, text) => step(value, c.parse_cirru_edn(text));
const command = (value, text) => step(value, c.option_$o_unwrap(run_command(
  c.parse_cirru_list(text), read(value, "main-hint"), read(value, "secondary-hint"), read(value, "slide-key"),
)));

test("slide selection and actual drawing commands retain geometry and snapshots", () => {
  assert.equal(command(store, "add-circle"), store); // No selected slide must not erase the root.
  let value = send(store, ":: :add-slide-after nil");
  const key = c._$n_set_$o_to_list(c.keys(read(value, "slides"))).toArray()[0];
  assert.equal(c.option_$o_none_$q_(read(value, "slide-key")), true); // Add does not select.
  value = send(value, `:: :switch-slide |${key}`);
  value = command(value, "add-rect");
  value = send(value, ":: :move-secondary-hint ([] 160 130)");
  value = command(value, "add-circle");
  const slide = c.option_$o_unwrap(c.get(read(value, "slides"), key));
  const logs = read(slide, "logs").toArray();
  assert.equal(logs.length, 2);
  assert.deepEqual(read(read(logs[0], "op"), "position").toArray(), [10, 10]);
  assert.deepEqual(read(read(logs[0], "op"), "sizes").toArray(), [30, 30]);
  assert.deepEqual(read(read(logs[1], "op"), "position").toArray(), [85, 70]);
  assert.equal(read(read(logs[1], "op"), "radius"), Math.hypot(150, 120) / 2);
  assert.equal(read(logs[0], "snapshot").toArray().length, 1);
  assert.equal(read(logs[1], "snapshot").toArray().length, 2);
  value = command(value, "add-slide");
  assert.equal(c.count(c.keys(read(value, "slides"))), 2);
  value = command(value, "del-slide");
  assert.equal(c.option_$o_none_$q_(c.get(read(value, "slides"), key)), true);
});

test("legacy Map hydration and mixed slide/widget cursor preserve typed root", () => {
  const legacy = c.parse_cirru_edn(`{} (:slide-key nil)
  :states $ {}
  :slides $ {} $ |T $ {} $ :logs $ []
  :main-hint $ [] 10 10
  :secondary-hint $ [] 40 40`);
  let value = step(store, c._$o__$o_(t["hydrate-storage"], legacy));
  assert.ok(c.struct_$q_(value));
  assert.equal(c.option_$o_none_$q_(read(value, "slide-key")), true);
  assert.ok(c.struct_$q_(decode_store(legacy)));
  value = send(value, ":: :states ([] |T :spin) ({} (:pointer 7) (:spin-pos ([] 250 -120)))");
  const slideStates = c.option_$o_unwrap(c.get(read(value, "states"), "T"));
  const widgetState = read(read(slideStates, "spin"), "data");
  assert.equal(read(widgetState, "pointer"), 7);
  assert.deepEqual(read(widgetState, "spin-pos").toArray(), [250, -120]);
  assert.ok(c.struct_$q_(c.option_$o_unwrap(c.get(read(value, "slides"), "T"))));
});
