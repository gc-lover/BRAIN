---
**api-readiness:** ready  
**api-readiness-check-date:** 2025-11-05 19:20  
**api-readiness-notes:** JSON-схема для quests.json с полными полями для skill-checks, диалогов, ветвлений, репутации и лута.
---

# JSON-схема для quests.json

## Базовая структура квеста

```json
{
  "questId": "string (unique)",
  "title": "string",
  "description": "string",
  "era": "2020-2030 | 2030-2045 | 2045-2060 | 2060-2077 | 2077 | 2078-2093",
  "type": "main | side | worldEvent",
  "level": {
    "min": "number",
    "max": "number"
  },
  "prerequisites": ["questId1", "questId2"],
  "nextQuests": ["questId1", "questId2"],
  "factions": {
    "primary": ["faction1", "faction2"],
    "secondary": ["faction3"],
    "conflicts": ["faction4"]
  },
  "classes": {
    "primary": ["class1"],
    "secondary": ["class2", "class3"],
    "cooperative": true
  },
  "origins": ["origin1", "origin2"],
  "dialogueTree": {},
  "skillChecks": [],
  "reputationChanges": {},
  "loot": {},
  "consequences": {},
  "worldEvents": []
}
```

## Диалоговое дерево (dialogueTree)

```json
{
  "dialogueTree": {
    "rootNode": 1,
    "nodes": [
      {
        "nodeId": 1,
        "npc": "NPC_ID",
        "npcName": "Display Name",
        "location": "locationId",
        "dialogue": "Текст диалога NPC",
        "choices": [
          {
            "choiceId": "A1",
            "text": "Текст выбора",
            "nextNode": 2,
            "conditions": {
              "reputation": {
                "faction": "NetWatch",
                "min": 10
              },
              "flags": ["flag1", "flag2"],
              "items": ["itemId"],
              "class": "Netrunner",
              "origin": "StreetKid"
            },
            "skillCheck": "SC-001",
            "reputationChange": {
              "NetWatch": 2
            },
            "flags": {
              "set": ["flag1"],
              "unset": ["flag2"]
            }
          }
        ],
        "skillChecks": [
          {
            "checkId": "SC-001",
            "type": "Social | Combat | Hacking | Tech | Stealth | Other",
            "dc": 14,
            "skill": "Persuasion | Intimidation | Hacking | etc",
            "attribute": "EMP | INT | REF | etc",
            "advantage": ["condition1", "condition2"],
            "disadvantage": ["condition3"],
            "success": {
              "nextNode": 3,
              "reputation": {"NetWatch": 2},
              "loot": {"eddy": 100},
              "flags": {"set": ["successFlag"]}
            },
            "failure": {
              "nextNode": 4,
              "reputation": {"NetWatch": -1},
              "flags": {"set": ["failureFlag"]}
            },
            "criticalSuccess": {
              "nextNode": 5,
              "reputation": {"NetWatch": 5},
              "loot": {"eddy": 200, "items": ["rareItem"]},
              "flags": {"set": ["criticalSuccessFlag"]}
            },
            "criticalFailure": {
              "nextNode": 6,
              "reputation": {"NetWatch": -5},
              "combat": true,
              "flags": {"set": ["criticalFailureFlag"]}
            }
          }
        ],
        "flags": {
          "required": ["flag1"],
          "blocks": ["flag2"]
        },
        "reputation": {
          "required": {
            "faction": "NetWatch",
            "min": 5
          }
        }
      }
    ]
  }
}
```

## Skill Checks (skillChecks)

```json
{
  "skillChecks": [
    {
      "checkId": "SC-001",
      "nodeId": 1,
      "name": "Узнать информацию",
      "type": "Social",
      "dc": 14,
      "skill": "Persuasion",
      "attribute": "EMP",
      "formula": "d20 + floor((EMP-10)/2) + Persuasion + modifiers",
      "modifiers": {
        "base": 0,
        "reputation": {
          "NetWatch": 2,
          "if": {"reputation": {"NetWatch": {"min": 10}}}
        },
        "items": {
          "CharismaImplant": 1
        },
        "class": {
          "Rockerboy": 2,
          "if": {"class": "Rockerboy"}
        },
        "origin": {
          "Corpo": 1,
          "if": {"origin": "Corpo"}
        },
        "flags": {
          "flag1": 2
        }
      },
      "advantage": {
        "conditions": ["NetWatchContract", "CleanNodeKey"],
        "effect": "roll twice, take higher"
      },
      "disadvantage": {
        "conditions": ["NetWatchHeat", "Injured"],
        "effect": "roll twice, take lower"
      },
      "criticalSuccess": {
        "threshold": 20,
        "effect": {
          "reputation": {"NetWatch": 5},
          "loot": {"eddy": 200},
          "flags": {"set": ["criticalSuccess"]},
          "nextNode": 5
        }
      },
      "criticalFailure": {
        "threshold": 1,
        "effect": {
          "reputation": {"NetWatch": -5},
          "combat": true,
          "flags": {"set": ["criticalFailure"]},
          "nextNode": 6
        }
      },
      "success": {
        "reputation": {"NetWatch": 2},
        "loot": {"eddy": 100},
        "nextNode": 3
      },
      "failure": {
        "reputation": {"NetWatch": -1},
        "nextNode": 4
      },
      "cooperative": {
        "allowedClasses": ["Netrunner", "Techie"],
        "bonus": 2,
        "effect": "helper adds +2 to roll"
      },
      "groupCheck": {
        "type": "cooperative | team | roleBased",
        "roles": ["tank", "dps", "support"],
        "successThreshold": 2,
        "effect": "if 2+ succeed, all succeed"
      }
    }
  ]
}
```

## Репутация (reputationChanges)

```json
{
  "reputationChanges": {
    "pathA": {
      "NetWatch": 15,
      "VoodooBoys": -5,
      "Arasaka": 0,
      "Militech": 0
    },
    "pathB": {
      "NetWatch": -10,
      "VoodooBoys": 15,
      "Arasaka": 0,
      "Militech": 0
    },
    "pathC": {
      "NetWatch": 5,
      "VoodooBoys": 5,
      "heat": 2
    },
    "pathM": {
      "NetWatch": -25,
      "VoodooBoys": 10,
      "AICompanion": 5
    },
    "skillChecks": {
      "SC-001": {
        "success": {"NetWatch": 2},
        "failure": {"NetWatch": -1},
        "criticalSuccess": {"NetWatch": 5},
        "criticalFailure": {"NetWatch": -5}
      }
    }
  }
}
```

## Лут (loot)

```json
{
  "loot": {
    "pathA": {
      "eddy": 500,
      "items": [
        {
          "itemId": "CleanNodeKey",
          "type": "implant | weapon | consumable | quest",
          "rarity": "rare",
          "quantity": 1,
          "modifiers": {
            "hackingDC": -2,
            "if": {"zone": "legal"}
          }
        }
      ],
      "reputation": {"NetWatch": 15},
      "experience": 500
    },
    "pathB": {
      "eddy": 800,
      "items": [
        {
          "itemId": "EchoTraceImplant",
          "type": "implant",
          "rarity": "epic",
          "quantity": 1,
          "modifiers": {
            "netPrediction": true
          }
        }
      ],
      "reputation": {"VoodooBoys": 15},
      "experience": 600
    },
    "lootTable": {
      "common": {
        "chance": 60,
        "items": [
          {"itemId": "item1", "chance": 30},
          {"itemId": "item2", "chance": 30}
        ]
      },
      "rare": {
        "chance": 30,
        "items": [
          {"itemId": "item3", "chance": 20},
          {"itemId": "item4", "chance": 10}
        ]
      },
      "epic": {
        "chance": 10,
        "items": [
          {"itemId": "item5", "chance": 10}
        ]
      }
    }
  }
}
```

## Последствия (consequences)

```json
{
  "consequences": {
    "nextQuestModifiers": {
      "MQ-2020-003": {
        "conditions": {
          "path": "A"
        },
        "modifiers": {
          "hackingDC": -2,
          "reputation": {"NetWatch": 5},
          "flags": ["NetWatchSupport"]
        }
      },
      "MQ-2020-003": {
        "conditions": {
          "path": "B"
        },
        "modifiers": {
          "heat": 1,
          "reputation": {"NetWatch": -5},
          "flags": ["VoodooBoysSupport"]
        }
      }
    },
    "eraModifiers": {
      "2030-2045": {
        "conditions": {
          "path": "A"
        },
        "modifiers": {
          "channelCrisisDC": -2,
          "reputation": {"NetWatch": 10},
          "access": ["NetWatchResources"]
        }
      },
      "2045-2060": {
        "conditions": {
          "path": "M",
          "flags": ["AICompanion"]
        },
        "modifiers": {
          "aiEvolution": true,
          "uniqueNPC": "AICompanion",
          "flags": ["AIAlly"]
        }
      }
    },
    "flags": {
      "set": ["questCompleted", "pathA"],
      "unset": ["questAvailable"]
    }
  }
}
```

## World Events (worldEvents)

```json
{
  "worldEvents": [
    {
      "eventId": "WE-2020-001",
      "name": "Случайная утечка данных",
      "type": "travel | random | scheduled",
      "trigger": {
        "location": "Watson",
        "chance": 0.15,
        "cooldown": 7200
      },
      "skillChecks": [
        {
          "checkId": "WE-SC-001",
          "type": "Hacking",
          "dc": 16,
          "success": {
            "loot": {"eddy": 100, "items": ["dataFragment"]},
            "reputation": {"NetWatch": 1}
          },
          "failure": {
            "heat": 1,
            "reputation": {"NetWatch": -1}
          }
        }
      ],
      "loot": {
        "eddy": 100,
        "items": ["dataFragment"]
      }
    }
  ]
}
```

## Полный пример квеста (MQ-2020-002)

```json
{
  "questId": "MQ-2020-002",
  "title": "Узел Триака",
  "description": "NetWatch засёк аномальные пакеты в старом корп-узле Triaka Industries.",
  "era": "2020-2030",
  "type": "main",
  "level": {"min": 5, "max": 10},
  "prerequisites": ["MQ-2020-001"],
  "nextQuests": ["MQ-2020-003"],
  "factions": {
    "primary": ["NetWatch", "VoodooBoys"],
    "secondary": [],
    "conflicts": ["NetWatch", "VoodooBoys"]
  },
  "classes": {
    "primary": ["Netrunner"],
    "secondary": ["Solo", "Techie"],
    "cooperative": true
  },
  "origins": [],
  "dialogueTree": {
    "rootNode": 1,
    "nodes": [
      {
        "nodeId": 1,
        "npc": "BrianMorris",
        "npcName": "Брайан Моррис",
        "location": "NetWatchHQ",
        "dialogue": "NetWatch засёк аномальные пакеты в старом корп-узле Triaka Industries. Нужна твоя помощь.",
        "choices": [
          {
            "choiceId": "A1",
            "text": "Я готов помочь NetWatch.",
            "nextNode": 2,
            "reputationChange": {"NetWatch": 5}
          },
          {
            "choiceId": "A2",
            "text": "Мне нужно подумать.",
            "nextNode": 3
          },
          {
            "choiceId": "A3",
            "text": "Что за аномалия?",
            "nextNode": 4,
            "skillCheck": "SC-001"
          }
        ]
      }
    ]
  },
  "skillChecks": [
    {
      "checkId": "SC-001",
      "nodeId": 1,
      "name": "Узнать информацию",
      "type": "Social",
      "dc": 14,
      "skill": "Persuasion",
      "attribute": "EMP",
      "formula": "d20 + floor((EMP-10)/2) + Persuasion + modifiers",
      "modifiers": {
        "base": 0,
        "reputation": {
          "NetWatch": 2,
          "if": {"reputation": {"NetWatch": {"min": 10}}}
        },
        "class": {
          "Rockerboy": 2,
          "if": {"class": "Rockerboy"}
        }
      },
      "success": {
        "nextNode": 5,
        "reputation": {"NetWatch": 2},
        "flags": {"set": ["infoReceived"]}
      },
      "failure": {
        "nextNode": 3,
        "reputation": {"NetWatch": -1}
      },
      "criticalSuccess": {
        "threshold": 20,
        "effect": {
          "reputation": {"NetWatch": 5},
          "flags": {"set": ["detailedInfo"]},
          "nextNode": 6
        }
      },
      "criticalFailure": {
        "threshold": 1,
        "effect": {
          "reputation": {"NetWatch": -5},
          "flags": {"set": ["suspicion"]},
          "nextNode": 3
        }
      }
    }
  ],
  "reputationChanges": {
    "pathA": {"NetWatch": 15, "VoodooBoys": -5},
    "pathB": {"NetWatch": -10, "VoodooBoys": 15},
    "pathC": {"NetWatch": 5, "VoodooBoys": 5, "heat": 2},
    "pathM": {"NetWatch": -25, "VoodooBoys": 10, "AICompanion": 5}
  },
  "loot": {
    "pathA": {
      "eddy": 500,
      "items": [{"itemId": "CleanNodeKey", "type": "implant", "rarity": "rare"}],
      "reputation": {"NetWatch": 15},
      "experience": 500
    },
    "pathB": {
      "eddy": 800,
      "items": [{"itemId": "EchoTraceImplant", "type": "implant", "rarity": "epic"}],
      "reputation": {"VoodooBoys": 15},
      "experience": 600
    }
  },
  "consequences": {
    "nextQuestModifiers": {
      "MQ-2020-003": {
        "conditions": {"path": "A"},
        "modifiers": {"hackingDC": -2, "flags": ["NetWatchSupport"]}
      }
    },
    "eraModifiers": {
      "2030-2045": {
        "conditions": {"path": "A"},
        "modifiers": {"channelCrisisDC": -2, "access": ["NetWatchResources"]}
      }
    }
  }
}
```

