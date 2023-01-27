const gen = require("crossword-layout-generator");

const wd = [
  "soupe",
  "assis",
  "visite",
  "malin",
  "maudit",
  "souci",
  "soucieux",
  "souffrir",
  "souffle",
];

function random_letter() {
  const letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  return letters[Math.floor(Math.random() * letters.length)];
}

function inverse_str(str) {
  return str.split("").reverse().join("");
}

function generate_grid(w = []) {
  const words = w.map((e) => ({
    answer: Math.random() > 0.5 ? e : inverse_str(e),
    clue: "",
  }));

  let gn = gen.generateLayout(words).table;
  let tries = 0;
  while (gn[0].length > 12 || gn.length > 12) {
    if (tries > 1000) break;
    gen.generateLayout(words).table;
    tries++;
  }

  let json = [];
  for (let i = 0; i < gn.length; i++) {
    gn[i] = gn[i].map((e) => (e === "-" ? random_letter() : e.toUpperCase()));
    json.push(gn[i]);
  }

  return json;
}

const express = require("express");
const app = express();

app.get("/", (req, res) => {
    if (req.query.words) res.json(generate_grid(req.query.words.split(",")));
    else res.status(400).json("No words provided");
});

app.listen(3000, () => {
  console.log("Server running on port http://localhost:3000");
});
