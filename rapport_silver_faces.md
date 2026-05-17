# Détection des _Silver Faces_ par Régression Logistique

### Application à l'analyse géométrique de surfaces CATIA V5

---

## 1. Contexte et objectif

Une _silver face_ est une surface dégénérée produite par CATIA V5 lors d'opérations booléennes ou de congés mal définis. Elle se caractérise par une géométrie extrêmement allongée : une très grande dimension dans un sens, et une dimension quasi nulle dans l'autre. Ces surfaces parasites provoquent des défauts de maillage, des échecs d'analyse éléments finis et des artefacts visuels dans les rendus.

L'objectif est de **classer automatiquement** chaque surface comme _saine_ ou _silver face_ à partir de ses seules propriétés géométriques mesurables, sans intervention humaine.

---

## 2. Caractéristiques géométriques utilisées

Quatre indicateurs géométriques sont extraits pour chaque surface :

| Caractéristique  | Symbole | Formule                                        | Interprétation                                         |
| ---------------- | ------- | ---------------------------------------------- | ------------------------------------------------------ |
| Compacité        | $C$     | $\displaystyle C = \frac{4\pi A}{P^2}$         | 1 pour un cercle parfait, ≈ 0 pour une forme dégénérée |
| Aire             | $A$     | —                                              | Surface en mm²                                         |
| Rapport d'aspect | $AR$    | $\displaystyle AR = \frac{L_{\max}}{L_{\min}}$ | 1 pour un carré, très grand pour une silver face       |
| Périmètre        | $P$     | —                                              | Longueur du contour en mm                              |

La compacité est le descripteur le plus discriminant : une _silver face_ possède une compacité proche de zéro ($C \ll 0.1$) et un rapport d'aspect très élevé ($AR \gg 60$).

---

## 3. Espace des caractéristiques

Les deux graphiques ci-dessous représentent la distribution des 1 500 surfaces dans l'espace des caractéristiques. Les surfaces saines apparaissent en vert, les _silver faces_ en rouge.

![Espace des caractéristiques — Compacité vs Rapport d'aspect et Aire](fig2_feature_space.png)

**Interprétation :**

- Dans le plan Compacité × Rapport d'aspect (gauche), les deux classes se séparent nettement : les _silver faces_ occupent la région de faible compacité ($C < 0.15$) et de rapport d'aspect élevé.
- La zone d'ambiguïté (encadrée en orange) correspond à $C \in [0.05, 0.15]$ et $AR \in [30, 60]$ : des surfaces saines très allongées (grandes faces planes) peuvent y coexister avec des _silver faces_ modérées.
- Dans le plan Compacité × Aire (droite), la compacité reste le critère dominant, indépendamment de la taille absolue de la surface.

---

## 4. Modèle : Régression Logistique

### 4.1 Normalisation des données

Avant l'entraînement, chaque caractéristique est normalisée par le **z-score** calculé sur le jeu d'entraînement uniquement (pas de fuite de données vers le jeu de test) :

$$z_i = \frac{x_i - \mu_i}{\sigma_i}$$

| Symbole    | Définition                                   |
| ---------- | -------------------------------------------- |
| $x_i$      | valeur brute de la caractéristique $i$       |
| $\mu_i$    | moyenne calculée sur le jeu d'entraînement   |
| $\sigma_i$ | écart-type calculé sur le jeu d'entraînement |

Cette étape est indispensable : les caractéristiques ont des ordres de grandeur très différents (l'aire peut valoir 2 000 mm² tandis que la compacité vaut 0.001), ce qui déséquilibrerait sinon le processus d'optimisation.

### 4.2 Fonction de décision

La régression logistique associe à chaque surface un score linéaire $z$, puis le transforme en probabilité via la **fonction sigmoïde** :

$$P(\text{silver face} \mid \mathbf{x}) = \sigma(z) = \frac{1}{1 + e^{-z}}, \qquad z = \mathbf{w}^\top \tilde{\mathbf{x}} + b$$

où $\mathbf{w}$ est le vecteur des poids appris, $\tilde{\mathbf{x}}$ le vecteur des caractéristiques normalisées, et $b$ le biais.

La décision finale dépend d'un **seuil de classification** $\tau$ :

$$\hat{y} = \begin{cases} 1 \text{ (silver face)} & \text{si } P \geq \tau \\ 0 \text{ (surface saine)} & \text{sinon} \end{cases}$$

---

## 5. Analyse des résultats

### 5.1 Courbe sigmoïde

![Courbe sigmoïde](fig3a_sigmoid.png)

**Interprétation :**
Chaque point du nuage représente une surface du jeu de test, projetée sur la courbe sigmoïde selon son score linéaire $z$. Les points verts (surfaces saines) se concentrent dans la zone $z < 0$ (probabilité faible), et les points rouges (_silver faces_) dans la zone $z > 0$ (probabilité élevée). La séparation nette des deux nuages confirme la qualité de la discrimination linéaire. Les rares points dans la zone centrale ($z \approx 0$) correspondent aux cas ambigus de la zone de chevauchement.

---

### 5.2 Distribution des probabilités prédites

![Distribution des probabilités sur le jeu de test](fig3b_prob_distribution.png)

**Interprétation :**
Un modèle bien calibré produit deux pics séparés : un pic proche de 0 (surfaces saines) et un pic proche de 1 (_silver faces_). Ce graphique permet de visualiser le **recouvrement** entre les deux distributions, i.e. les surfaces difficiles à classer. Plus les deux histogrammes sont séparés et étroits, plus le modèle est confiant.

---

### 5.3 Courbe ROC

![Courbe ROC](fig3c_roc.png)

La courbe ROC (_Receiver Operating Characteristic_) représente le compromis entre le **taux de vrais positifs** (rappel, TPR) et le **taux de faux positifs** (FPR) pour tous les seuils $\tau$ possibles.

$$\text{TPR} = \frac{VP}{VP + FN}, \qquad \text{FPR} = \frac{FP}{FP + VN}$$

L'**aire sous la courbe** (AUC) synthétise la performance globale, indépendamment du seuil :

| AUC   | Interprétation                       |
| ----- | ------------------------------------ |
| 1.0   | Séparation parfaite des deux classes |
| 0.5   | Modèle aléatoire (diagonale)         |
| < 0.5 | Pire qu'un classifieur aléatoire     |

**Interprétation :** Une AUC proche de 1 indique que le modèle sépare efficacement les deux classes sur l'ensemble des seuils possibles. La courbe reste proche du coin supérieur gauche, ce qui traduit un faible taux de faux positifs même à un rappel élevé.

---

### 5.4 Courbe Précision-Rappel

![Courbe Précision-Rappel](fig3d_precision_recall.png)

La courbe PR est particulièrement adaptée aux **jeux de données déséquilibrés** (ici 73 % saines / 27 % _silver faces_). Elle représente le compromis entre :

$$\text{Précision} = \frac{VP}{VP + FP}, \qquad \text{Rappel} = \frac{VP}{VP + FN}$$

- **Précision** : parmi les surfaces détectées comme _silver face_, quelle fraction l'est vraiment ?
- **Rappel** : parmi toutes les _silver faces_ réelles, quelle fraction le modèle détecte-t-il ?

**Interprétation :** Dans un contexte de contrôle qualité, le **rappel** est prioritaire — manquer une _silver face_ (faux négatif) est plus coûteux qu'une fausse alarme. Un seuil abaissé à $\tau = 0.3$ augmente le rappel au prix d'une légère diminution de la précision.

---

### 5.5 Frontière de décision

![Frontière de décision dans le plan Compacité × Rapport d'aspect](fig4_decision_boundary.png)

**Interprétation :**
Le fond coloré représente la probabilité prédite par le modèle sur l'ensemble du plan (vert = faible probabilité d'être une _silver face_, beige = forte probabilité). Les deux courbes de niveau correspondent aux seuils $\tau = 0.5$ (tirets) et $\tau = 0.3$ (pointillés). Le seuil 0.3 est décalé vers la zone saine, ce qui permet de capturer davantage de _silver faces_ au prix d'un léger empiétement sur les surfaces saines ambiguës.

---

## 6. Métriques de classification

### 6.1 Matrice de confusion — seuil standard $\tau = 0.5$

![Matrice de confusion, seuil 0.5](fig5a_confusion_05.png)

### 6.2 Matrice de confusion — seuil recommandé $\tau = 0.3$

![Matrice de confusion, seuil 0.3](fig5b_confusion_03.png)

Les quatre cases de la matrice de confusion :

|                        | Prédit saine        | Prédit silver face  |
| ---------------------- | ------------------- | ------------------- |
| **Réelle saine**       | Vrais négatifs (VN) | Faux positifs (FP)  |
| **Réelle silver face** | Faux négatifs (FN)  | Vrais positifs (VP) |

**Interprétation comparative :**
Avec le seuil standard $\tau = 0.5$, le modèle est plus conservateur : il ne classe _silver face_ que les cas très probables, réduisant les faux positifs mais augmentant le risque de faux négatifs (des _silver faces_ non détectées). Avec $\tau = 0.3$, le modèle est plus sensible : il détecte plus de _silver faces_ réelles au prix d'un nombre légèrement plus élevé de fausses alarmes. Dans un pipeline de contrôle qualité automatisé, ce compromis est préférable.

---

## 7. Interprétabilité — poids du modèle

![Poids appris par la régression logistique](fig6_weights.png)

**Interprétation :**
Les poids $w_i$ indiquent la contribution de chaque caractéristique normalisée à la décision finale. Un coefficient **positif** (rouge) pousse la prédiction vers _silver face_ ; un coefficient **négatif** (vert) la pousse vers _surface saine_.

- Le **rapport d'aspect** ($AR$) est le facteur le plus influent en faveur d'une détection _silver face_ : plus $AR$ est élevé, plus la surface est suspecte.
- La **compacité** ($C$) est le facteur protecteur dominant : une compacité élevée est une forte indication de surface saine.
- L'**aire** et le **périmètre** jouent un rôle secondaire, affinant la décision dans les cas ambigus.

---

## 8. Conclusion et recommandations

Le modèle de régression logistique entraîné sur 1 500 surfaces synthétiques démontre une capacité de discrimination robuste entre surfaces saines et _silver faces_, avec une AUC supérieure à 0.95.

**Recommandations pour la mise en production :**

1. **Seuil de classification** : utiliser $\tau = 0.3$ plutôt que le seuil standard 0.5, afin de maximiser la détection des _silver faces_ dans un contexte de contrôle qualité.
2. **Indicateurs à surveiller** : compacité $C$ et rapport d'aspect $AR$ sont les deux signaux les plus discriminants. Une surface avec $C < 0.05$ et $AR > 100$ doit être systématiquement signalée.
3. **Intégration CATIA** : le modèle peut être appelé depuis un script VBScript (`silver_faces.vbs`) en extrayant les quatre caractéristiques géométriques via les APIs de mensuration CATIA V5.
