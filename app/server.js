const express = require("express");
const app = express();

app.get("/", (req, res) => {
  res.send("App deployed successfully on ECS Fargate using HCP Terraform!");
});

app.listen(3000, () => console.log("Server running on port 3000"));
