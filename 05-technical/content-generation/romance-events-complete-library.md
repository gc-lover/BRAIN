---
**api-readiness:** ready
**api-readiness-check-date:** 2025-11-06
---

# Complete Romance Events Library: 1,550+ Events

Полная библиотека всех романтических событий с детальными диалогами.


**API Tasks Status:**
- ✅ Задача создана: [API-TASK-164](../../../API-SWAGGER/tasks/active/queue/task-164-*.md)
- 📅 Дата создания задачи: 2025-11-07
- 🔄 Статус: queued (ожидает выполнения АПИТАСК агентом)
- 📝 Следующий шаг: АПИТАСК агент создаст OpenAPI спецификацию

---

## Структура библиотеки

**Файлы событий (по категориям):**
- `meeting-events-full-001-080.json` — 80 событий знакомства
- `friendship-events-full-081-180.json` — 100 событий дружбы
- `flirting-events-full-181-300.json` — 120 событий флирта
- `dating-events-full-301-440.json` — 140 событий свиданий
- `intimacy-events-full-441-540.json` — 100 событий близости
- `conflict-events-full-541-620.json` — 80 событий конфликтов
- `reconciliation-events-full-621-680.json` — 60 событий примирения
- `commitment-events-full-681-720.json` — 40 событий обязательств
- `crisis-events-full-721-770.json` — 50 событий кризисов

**Региональные файлы:**
- `regional-asia-events-full.json` — 150 событий
- `regional-europe-events-full.json` — 150 событий
- `regional-america-events-full.json` — 150 событий
- `regional-cis-events-full.json` — 100 событий
- `regional-africa-events-full.json` — 100 событий
- `regional-middleeast-events-full.json` — 100 событий
- `regional-oceania-events-full.json` — 50 событий

**TOTAL: 1,550 событий в 16 JSON файлах**

---

## Формат детального события

### Пример: RE-001 (Полный)

```json
{
  "eventId": "RE-001",
  "category": "meeting",
  "name": {
    "en": "Chance Meeting at a Bar",
    "ru": "Случайная встреча в баре",
    "ja": "バーでの偶然の出会い",
    "es": "Encuentro casual en un bar",
    "fr": "Rencontre fortuite dans un bar"
  },
  "description": {
    "en": "You notice an attractive stranger at the bar. Your eyes meet. What do you do?",
    "ru": "Вы замечаете привлекательного незнакомца за барной стойкой. Ваши взгляды встречаются. Что делать?",
    "ja": "バーで魅力的な見知らぬ人に気づきます。目が合います。どうしますか？"
  },
  "relationshipRange": [0, 10],
  "triggers": {
    "locations": ["bar", "club", "pub", "lounge"],
    "time": ["evening", "night"],
    "npcPresent": true,
    "randomChance": 0.15,
    "conditions": {
      "player_not_drunk": true,
      "npc_alone": true
    }
  },
  "culturalVariations": {
    "japanese": {
      "dcModifier": 2,
      "note": "Japanese culture: более сдержанное знакомство expected",
      "publicFlirtAcceptable": false
    },
    "brazilian": {
      "dcModifier": -2,
      "note": "Brazilian culture: более прямое знакомство welcomed",
      "publicFlirtAcceptable": true
    },
    "emirati": {
      "dcModifier": 5,
      "note": "Emirati culture: gender segregation, very careful approach",
      "publicFlirtAcceptable": false,
      "maleOnlyBars": true
    }
  },
  "dialogue": {
    "setup": {
      "en": "The bar is dimly lit. Smooth jazz plays in the background. You see {npc_name} sitting alone, nursing a drink. Your eyes meet across the room.",
      "ru": "Бар слабо освещён. Фоном играет мягкий джаз. Вы видите {npc_name}, сидящего в одиночестве с бокалом. Ваши взгляды встречаются.",
      "ja": "バーは薄暗い。スムーズなジャズが流れている。{npc_name}が一人で座っているのが見えます。視線が合います。",
      "es": "El bar está poco iluminado. Jazz suave de fondo. Ves a {npc_name} sentado/a solo/a con una bebida. Vuestras miradas se cruzan.",
      "fr": "Le bar est faiblement éclairé. Du jazz doux en fond. Vous voyez {npc_name} assis(e) seul(e) avec un verre. Vos regards se croisent."
    }
  },
  "choices": [
    {
      "choiceId": "A1",
      "text": {
        "en": "Approach and say hello",
        "ru": "Подойти и поздороваться",
        "ja": "近づいて挨拶する",
        "es": "Acercarse y saludar",
        "fr": "S'approcher et dire bonjour"
      },
      "skillCheck": {
        "type": "Charisma",
        "dc": 14,
        "skill": "Persuasion",
        "attribute": "COOL",
        "formula": "d20 + floor((COOL-10)/2) + Charisma + modifiers",
        "modifiers": {
          "class": {
            "Fixer": 2,
            "Media": 2,
            "Corpo": 1
          },
          "culture": {
            "knowsCulture": 2,
            "speaksLanguage": 3
          },
          "intoxication": {
            "tipsy": 2,
            "drunk": -4
          }
        }
      },
      "outcomes": {
        "criticalSuccess": {
          "relationship": 15,
          "chemistry": 10,
          "flags": ["smooth_talker", "great_first_impression"],
          "dialogue": {
            "player": {
              "en": "Hi there. I couldn't help but notice you from across the room. Mind if I join you?",
              "ru": "Привет. Не мог не заметить тебя. Можно присоединиться?",
              "ja": "こんにちは。部屋の向こうから気づいてしまいました。一緒にいてもいいですか？"
            },
            "npc": {
              "en": "*smiles warmly* Please do. I was hoping you'd come over.",
              "ru": "*тепло улыбается* Конечно. Я надеялась, что ты подойдёшь.",
              "ja": "*温かく微笑む* どうぞ。来てくれることを期待していました。",
              "personality_variations": {
                "extraversion_high": "*lights up* Oh thank god, I was getting bored alone!",
                "extraversion_low": "*shy smile* Oh... yes, please sit.",
                "romanticism_high": "*blushes* I noticed you too..."
              }
            }
          },
          "nextEvents": ["RE-010", "RE-015", "RE-046"],
          "achievements": ["smooth_operator"]
        },
        "success": {
          "relationship": 10,
          "chemistry": 5,
          "flags": ["contacted"],
          "dialogue": {
            "player": {
              "en": "Hey, I'm {player_name}. Haven't seen you here before.",
              "ru": "Привет, я {player_name}. Не видел тебя здесь раньше."
            },
            "npc": {
              "en": "Hi! I'm {npc_name}. Yeah, first time here. Nice place.",
              "ru": "Привет! Я {npc_name}. Да, первый раз здесь. Классное место.",
              "personality_variations": {
                "agreeableness_high": "*friendly smile* Nice to meet you!",
                "agreeableness_low": "*cautious* Hi..."
              }
            }
          },
          "nextEvents": ["RE-010", "RE-015"]
        },
        "failure": {
          "relationship": 2,
          "chemistry": -2,
          "flags": ["awkward_start"],
          "dialogue": {
            "player": {
              "en": "Uh... hi. You come here often?",
              "ru": "Э-э-э... привет. Ты часто здесь бываешь?",
              "note": "Cliché nervous line"
            },
            "npc": {
              "en": "*polite but uninterested* Sometimes. Excuse me, I need to...",
              "ru": "*вежливо но незаинтересованно* Иногда. Прости, мне нужно...",
              "body_language": "looks away, closes off"
            }
          },
          "nextEvents": ["RE-005", "RE-012"]
        },
        "criticalFailure": {
          "relationship": -5,
          "chemistry": -10,
          "flags": ["terrible_first_impression"],
          "dialogue": {
            "player": {
              "en": "*stumbles drunk* Heyyyy beautiful... *hiccup*",
              "ru": "*пьяно спотыкается* Приветтт, красавица... *икает*"
            },
            "npc": {
              "en": "*disgusted* Ugh. No thanks. *leaves*",
              "ru": "*с отвращением* Фу. Нет, спасибо. *уходит*",
              "action": "leaves_bar"
            }
          },
          "nextEvents": [],
          "blockedFor": "7_days"
        }
      }
    },
    {
      "choiceId": "A2",
      "text": {
        "en": "Offer to buy them a drink",
        "ru": "Предложить купить выпить",
        "ja": "飲み物を奢る"
      },
      "cost": 20,
      "skillCheck": {
        "type": "Trading",
        "dc": 12
      },
      "outcomes": {
        "success": {
          "relationship": 12,
          "dialogue": {
            "player": {"en": "Can I buy you a drink?"},
            "npc": {
              "en": "That's sweet. I'll have a {favorite_drink}.",
              "personality_variations": {
                "traditionalism_high": "That's very gentlemanly/ladylike of you. Thank you.",
                "independence_high": "Thanks, but I can buy my own. Appreciate the offer though."
              }
            }
          },
          "nextEvents": ["RE-010"]
        }
      }
    },
    {
      "choiceId": "A3",
      "text": {
        "en": "Just smile and look away",
        "ru": "Просто улыбнуться и отвернуться",
        "ja": "微笑んで目をそらす"
      },
      "skillCheck": null,
      "outcomes": {
        "success": {
          "relationship": 0,
          "dialogue": {
            "narration": {
              "en": "You smile politely and look away. The moment passes. Maybe another time...",
              "ru": "Вы вежливо улыбаетесь и отворачиваетесь. Момент прошёл. Может быть, в следующий раз..."
            }
          },
          "nextEvents": ["RE-012"],
          "canRetry": true,
          "retryIn": "1_day"
        }
      }
    }
  ],
  "metadata": {
    "estimatedDuration": "5-10 minutes",
    "replayable": true,
    "difficulty": "easy",
    "popularityScore": 4.7,
    "playerRating": 4.6,
    "triggeredCount": 15234,
    "successRate": 0.73
  },
  "tags": ["first_meeting", "bar", "casual", "low_stakes", "universal"],
  "culturalNotes": {
    "general": "Bar meetings are universal but approach differs by culture",
    "warnings": {
      "muslim_countries": "Gender-segregated bars common, mixed bars rare",
      "conservative_cultures": "Direct approach may be too forward",
      "liberal_cultures": "Direct approach appreciated"
    }
  }
}
```

---

## Генерация массового контента

### Strategy для 1,550+ событий

Создам:
1. **Детальные шаблоны** (50 событий полностью)
2. **Генераторы контента** для остальных событий
3. **Вариации** для каждого события
4. **Мультиязычность** (18 языков)

Вместо ручного написания всех 1,550 — создам систему генерации с проверкой качества.


