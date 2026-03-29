---
name: session-save
description: "Sauvegarde l'état de la session en cours — décisions, fichiers modifiés, statut actuel et prochaines étapes — dans un fichier de passation pour reprendre plus tard."
---

# /session-save

Capture la session en cours dans un fichier de passation structuré afin que vous (ou une autre instance) puissiez reprendre avec le contexte complet. Crée un fichier Markdown horodaté dans `.claude/sessions/`.

## Quand l'utiliser

- Avant de terminer une session qui n'est pas complète
- Avant de passer à une tâche différente
- Avant que le contexte atteigne 75%+ (pour préserver les éléments importants)
- Aux jalons naturels d'une tâche longue (après chaque phase)
- Pour passer la main à une deuxième instance Claude

## Instructions

Produire un document de passation avec la structure suivante :

---

## Passation de session — [HORODATAGE]

### Ce qui était en cours
[Un paragraphe : l'objectif, l'approche, où en sont les choses en ce moment]

### Fichiers modifiés durant cette session
[Lister chaque fichier créé, modifié ou supprimé — avec la nature du changement]

```
chemin/vers/fichier.ts      — [ce qui a changé et pourquoi]
chemin/vers/autre.ts        — [ce qui a changé et pourquoi]
```

### Décisions clés prises
[Choix architecturaux, compromis acceptés, approches rejetées et pourquoi]

- **Décision** : [Ce qui a été décidé]
  - **Justification** : [Pourquoi]
  - **Alternatives rejetées** : [Ce qui a été envisagé d'autre]

### Statut actuel
[Où en sont les choses maintenant — ce qui fonctionne, ce qui est cassé, ce qui est en cours]

- En fonctionnement : [...]
- En cours : [...]
- Problèmes connus : [...]

### Prochaines étapes (ordonnées)
[Les actions exactes à effectuer pour continuer — assez précises pour qu'un contexte vierge puisse reprendre sans tout relire]

1. [Première action] — `chemin/vers/fichier.ts` — [quoi faire]
2. [Deuxième action] — [...]
3. [...]

### Contexte à recharger
[Fichiers qui doivent être lus pour reprendre avec une compréhension complète — garder cette liste courte]

- `chemin/vers/fichier-clé.ts` — [pourquoi c'est important]
- `CLAUDE.md` — règles du projet

### Blocages / Questions ouvertes
[Tout ce qui n'est pas résolu et nécessite une décision ou une contribution externe avant de continuer]

- [ ] [Question ou blocage] — [qui/quoi peut le résoudre]

---

## Implémentation

Sauvegarder la passation dans `.claude/sessions/handoff-[YYYY-MM-DD-HHMM].md`. Puis afficher le chemin du fichier pour que l'utilisateur sache où le trouver.

## Modèle de reprise

Pour reprendre depuis une passation :

```
/session-resume .claude/sessions/handoff-YYYY-MM-DD-HHMM.md
```

Ou manuellement : lire le fichier de passation, puis lire les fichiers listés dans "Contexte à recharger" avant de continuer.

## Exemples

### Exemple 1 : Sauvegarde en milieu de fonctionnalité

```
/session-save
```

Claude capture :
- Le middleware d'authentification était en cours de refactorisation (fichiers : `src/middleware/auth.ts`, `src/middleware/jwt.ts`)
- Décision : passage des tokens de session aux JWT (justification : meilleure scalabilité sur plusieurs services)
- Statut : validation JWT fonctionnelle, logique de rafraîchissement en cours
- Prochaine étape : implémenter `refreshToken()` dans `src/services/auth.service.ts`, puis mettre à jour les tests

### Exemple 2 : Sauvegarde sous pression de contexte

Quand le contexte atteint 70%, lancer `/session-save` avant `/compact` pour préserver le contexte des décisions que la compaction pourrait perdre.

## Notes

- Garder "Contexte à recharger" à 5 fichiers maximum — l'objectif est une reprise rapide, pas une relecture complète
- "Prochaines étapes" doit être assez précis pour qu'un Claude démarrant à froid puisse exécuter l'étape 1 sans poser de questions
- Ne pas sauvegarder les sorties d'outils ou les extraits de code dans la passation — référencer les chemins de fichiers à la place

---

**Voir aussi** :
- [Session Teleportation](../../guide/ultimate-guide.md#916-session-teleportation) — patterns de gestion de session plus larges
- [Instinct-Based Learning](../../guide/ultimate-guide.md#924-instinct-based-continuous-learning) — ce qu'il faut extraire des sessions avant de les fermer
