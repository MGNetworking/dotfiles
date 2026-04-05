---
name: arch-check
description: "Vérification de l'architecture du projet — SOLID, règles de couche et conventions"
---

# Vérification de l'architecture du projet

Tu es un expert en architecture logicielle.

Commence par **détecter la stack technique** du projet (langage, framework, structure des dossiers) en lisant les fichiers de configuration présents (`package.json`, `*.csproj`, `pom.xml`, `go.mod`, `requirements.txt`, `Cargo.toml`, etc.) et en explorant l'arborescence.

Adapte toute ton analyse à la stack détectée.

---

## Ce que tu dois vérifier

### 1. Principes SOLID

Pour chaque principe, indique : ✅ Respecté / ⚠️ Violation partielle / ❌ Violation franche

**SRP — Single Responsibility Principle**
- Chaque classe/module a-t-il une seule raison de changer ?
- Les méthodes mélangent-elles validation, logique métier et persistance ?

**OCP — Open/Closed Principle**
- Peut-on changer une implémentation sans modifier les consommateurs ?
- Y a-t-il des `instanceof` / `is` / `typeof` vers des classes concrètes dans les couches hautes ?

**LSP — Liskov Substitution Principle**
- Les implémentations d'interfaces/classes abstraites honorent-elles leurs contrats ?
- Y a-t-il des méthodes non implémentées qui lèvent une exception par défaut ?

**ISP — Interface Segregation Principle**
- Les interfaces/contrats sont-ils ciblés et cohérents ?
- Un consommateur est-il forcé de dépendre de méthodes qu'il n'utilise pas ?

**DIP — Dependency Inversion Principle**
- Les modules de haut niveau dépendent-ils d'abstractions ou de classes concrètes ?
- Y a-t-il des instanciations directes (`new ConcreteClass()`) là où une injection serait attendue ?

---

### 2. Règles de couche

Identifie les couches présentes dans le projet, puis vérifie que les dépendances respectent la règle :

```
Couches hautes (API/UI/Controllers) → Couches métier (Services/UseCases) → Couches basses (Repositories/Infrastructure)
La couche Domain/Core ne dépend de RIEN d'externe
```

- Une couche basse importe-t-elle une couche haute ?
- Une couche métier importe-t-elle directement une implémentation concrète d'infrastructure ?
- Une couche haute contient-elle de la logique métier ?

---

### 3. Conventions du projet

Identifie les conventions utilisées dans le projet (nommage, structure, patterns récurrents) et vérifie leur cohérence :
- Le nommage est-il uniforme (casse, préfixes, suffixes) ?
- Les patterns utilisés sont-ils appliqués de façon cohérente dans tout le projet ?
- Y a-t-il des incohérences visibles entre fichiers similaires ?

---

## Format du rapport

```
## Rapport d'architecture — [date du jour]

### Stack détectée : [langage + framework]

### Score global : X/20

| Catégorie        | Score | Statut   |
|-----------------|-------|----------|
| SRP             | X/4   | ✅/⚠️/❌ |
| OCP             | X/4   | ✅/⚠️/❌ |
| LSP             | X/4   | ✅/⚠️/❌ |
| ISP             | X/4   | ✅/⚠️/❌ |
| DIP             | X/4   | ✅/⚠️/❌ |

### Violations détectées

Pour chaque violation :
- **Fichier** : chemin:ligne
- **Principe** : lequel
- **Description** : ce qui est incorrect
- **Correction suggérée** : comment le corriger

### Points forts

Liste des bonnes pratiques déjà en place.

### Priorités de correction

1. [violation la plus critique]
2. ...
```

## Instructions

1. Détecte la stack en lisant les fichiers de configuration à la racine.
2. Explore l'arborescence pour identifier les couches et les fichiers clés.
3. Lis les fichiers les plus représentatifs de chaque couche.
4. Produis le rapport complet.

$ARGUMENTS
