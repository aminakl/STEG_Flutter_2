# Backlog

## Épic 1 : Gestion des Notes d'Arrêt (Priorité Haute) - ✅ COMPLÉTÉ

1. **US001 - Création de notes d'arrêt** ✅  
   *En tant que chef d'exploitation, je veux émettre une note d'arrêt pour un ouvrage électrique.*  
   **Critères d'acceptation** : Formulaire de création, notification au Chef de Base, détails de l'ouvrage et du chargé d'exploitation.
   **Implémentation** : Formulaire complet avec sélection visuelle du type d'équipement (LIGNE_HT, TRANSFORMATEUR, COUPLAGE).

2. **US002 - Validation des notes d'arrêt** ✅  
   *En tant que Chef de Base, je veux valider ou rejeter une note d'arrêt.*  
   **Critères d'acceptation** : Affichage des notes en attente, approbation/rejet avec motifs, notification au chargé d'exploitation.
   **Implémentation** : Workflow de validation multi-étapes avec notifications en temps réel.

3. **US003 - Modification des notes d'arrêt** ✅  
   *En tant que chef d'exploitation, je veux modifier une note d'arrêt rejetée.*  
   **Critères d'acceptation** : Révision des motifs de rejet, renvoi automatique au Chef de Base.
   **Implémentation** : Interface de modification avec affichage des motifs de rejet et soumission automatique.

4. **US004 - Réception des notes d'arrêt validées** ✅  
   *En tant que chargé d'exploitation, je veux recevoir et confirmer les notes d'arrêt validées.*  
   **Critères d'acceptation** : Affichage des notes validées, fonction de confirmation.
   **Implémentation** : Tableau de bord filtrable avec notifications pour les nouvelles notes validées.

5. **US005 - Désignation du chargé de consignation** ✅  
   *En tant que chargé d'exploitation, je veux désigner un chargé de consignation.*  
   **Critères d'acceptation** : Notification au chargé de consignation, accès à la note d'arrêt.
   **Implémentation** : Interface d'assignation avec sélection des utilisateurs ayant le rôle CHARGE_CONSIGNATION.

## Épic 2 : Processus de Consignation (Priorité Haute) - ✅ COMPLÉTÉ

6. **US006 - Initiation d'une consignation** ✅  
   *En tant que chargé de consignation, je veux initier une nouvelle consignation.*  
   **Critères d'acceptation** :
   1. Sélection de l'ouvrage HT, génération d'un numéro unique, lancement d'un chronomètre.
   2. **Vérification automatique des 5 règles de sécurité** avant validation (ex : isolation électrique, vérification de l'absence de tension, pose de cadenas).
   **Implémentation** : Interface de création de fiche de manœuvre avec vérification des EPI obligatoire avant de commencer la consignation.

7. **US007 - Suivi des étapes de consignation** ✅  
   *En tant que chargé de consignation, je veux suivre les étapes de consignation.*  
   **Critères d'acceptation** :
   1. Sélection des étapes prédéfinies, enregistrement de la durée.
   2. **Blocage de l'étape suivante si une règle de sécurité n'est pas respectée**.
   **Implémentation** : Timeline interactive des étapes de consignation avec suivi du temps pour chaque étape et blocage si les EPI ne sont pas vérifiés.

8. **US008 - Vérification de la fiche de manœuvre** ✅  
   *En tant que chargé d'exploitation, je veux vérifier la fiche de manœuvre.*  
   **Critères d'acceptation** : Accès à la fiche, notification au chargé de consignation, génération d'une fiche finale.
   **Implémentation** : Génération de PDF pour les fiches de manœuvre et notifications automatiques.

9. **US009 - Suivi de l'avancement de la consignation** ✅  
   *En tant que chef d'exploitation, je veux suivre l'avancement de la consignation.*  
   **Critères d'acceptation** : Affichage en temps réel des étapes, alertes en cas de retard.
   **Implémentation** : Tableau de bord avec indicateurs de progression en temps réel et notifications d'étapes.

## Épic 3 : Processus de Déconsignation (Priorité Moyenne) - ✅ COMPLÉTÉ

10. **US010 - Suivi des opérations de déconsignation** ✅  
    *En tant que chargé de consignation, je veux suivre les opérations de déconsignation.*  
    **Critères d'acceptation** : Affichage des opérations en temps réel, récapitulatif des étapes.
    **Implémentation** : Interface similaire à la consignation avec timeline des étapes de déconsignation.

11. **US011 - Notifications en cas d'incident** ✅  
    *En tant que chargé de consignation, je peux émettre des notifications en cas d'incident.*  
    **Critères d'acceptation** : Notifications push pour les incidents ou anomalies.
    **Implémentation** : Système de notifications en temps réel avec badges et alertes.

12. **US012 - Suivi de l'avancement de la déconsignation** ✅  
    *En tant que chef d'exploitation, je veux suivre l'avancement de la déconsignation.*  
    **Critères d'acceptation** : Affichage en temps réel, alertes en cas de retard.
    **Implémentation** : Tableau de bord avec indicateurs de progression et notifications d'étapes.

## Épic 4 : Début et Fin des Travaux (Priorité Moyenne) - ✅ COMPLÉTÉ

13. **US013 - Début des travaux** ✅  
    *En tant que chargé de consignation, je veux marquer le début des travaux.*  
    **Critères d'acceptation** : Fonction de validation du début des travaux.
    **Implémentation** : Bouton de démarrage des travaux avec enregistrement de l'horodatage.

14. **US014 - Délivrance des attestations de consignation** ✅  
    *En tant que chargé de consignation, je veux délivrer des attestations de consignation.*  
    **Critères d'acceptation** : Ajout des noms des chargé des travaux avec leurs habilitations.
    **Implémentation** : Interface de création d'attestations avec sélection des utilisateurs ayant le rôle CHARGE_TRAVAUX et génération de PDF.

15. **US015 - Validation de la fin des travaux** ✅  
    *En tant que chargé de consignation, je veux valider la fin des travaux.*  
    **Critères d'acceptation** : Fonction de validation, notification au chargé d'exploitation.
    **Implémentation** : Bouton de fin des travaux avec notifications automatiques et mise à jour du statut.

## Épic 5 : Gestion des Modèles de Consignation et Déconsignation (Priorité Faible) - ✅ PARTIELLEMENT COMPLÉTÉ

16. **US016 - Création de modèles de consignation** ✅  
    *En tant que chargé de consignation, je veux créer un modèle de consignation.*  
    **Critères d'acceptation** : Ajout de schémas unifilaires, étapes prédéfinies, sauvegarde du modèle.
    **Implémentation** : Modèles prédéfinis basés sur le type d'équipement (LIGNE_HT, TRANSFORMATEUR, COUPLAGE).

17. **US017 - Création de modèles de déconsignation** ✅  
    *En tant que chargé de consignation, je veux créer un modèle de déconsignation.*  
    **Critères d'acceptation** : Similaire à US016, mais pour la déconsignation.
    **Implémentation** : Modèles prédéfinis pour les étapes de déconsignation basés sur le type d'équipement.

18. **US018 - Modification des modèles existants** ⚠️  
    *En tant que chargé de consignation, je veux modifier un modèle existant.*  
    **Critères d'acceptation** : Interface de modification, respect des règles de sécurité.
    **Implémentation partielle** : Possibilité de modifier les schémas en ajoutant des éléments GND et INTERRUPTEUR.

19. **US019 - Suppression des modèles inutiles** ⚠️  
    *En tant que chargé de consignation, je veux supprimer un modèle inutile.*  
    **Critères d'acceptation** : Option de suppression avec confirmation.
    **À implémenter** : Fonctionnalité de suppression des modèles personnalisés.

20. **US020 - Ajout de schémas unifilaires** ✅  
    *En tant que chargé de consignation, je veux ajouter des schémas unifilaires.*  
    **Critères d'acceptation** : Ajout d'images de schémas unifilaires.
    **Implémentation** : Canvas interactif pour la modification des schémas électriques.

## Épic 6 : Gestion des Intervenants (Utilisateurs) (Priorité Faible) - ✅ COMPLÉTÉ

21. **US021 - Création d'un nouvel intervenant** ✅  
    *En tant qu'administrateur, je veux créer un nouvel intervenant.*  
    **Critères d'acceptation** : Formulaire de création, attribution des permissions.
    **Implémentation** : Interface d'administration avec formulaire complet incluant nom complet, téléphone, unité et rôle.

22. **US022 - Modification des informations d'un intervenant** ✅  
    *En tant qu'administrateur, je veux modifier les informations d'un intervenant.*  
    **Critères d'acceptation** : Accès à la liste des intervenants, modification des permissions.
    **Implémentation** : Interface de modification des utilisateurs avec gestion des rôles.

23. **US023 - Désactivation ou suppression d'un intervenant** ✅  
    *En tant qu'administrateur, je veux désactiver ou supprimer un intervenant.*  
    **Critères d'acceptation** : Option de désactivation/suppression avec confirmation.
    **Implémentation** : Fonctionnalité de désactivation avec confirmation pour éviter les suppressions accidentelles.

## Épic 7 : Reporting et Tableaux de Bord (Priorité Faible) - ✅ PARTIELLEMENT COMPLÉTÉ

24. **US024 - Tableau de bord des notes d'arrêt et consignations** ✅  
    *En tant que chef d'exploitation, je veux accéder à un tableau de bord.*  
    **Critères d'acceptation** :
    - Affichage des indicateurs clés (notes d'arrêt, consignations validées et durée de la consignation).
    - Accès restreint au Chef d'Exploitation et Chef de Base.
    **Implémentation** : Tableau de bord avec graphiques de distribution des statuts, métriques de performance et tendances mensuelles.

25. **US025 - Génération de rapports détaillés** ✅  
    *En tant que chargé de consignation, je veux générer des rapports sur les consignations.*  
    **Critères d'acceptation** :
    - Informations détaillées (date, intervenants, durée), export en PDF.
    - Les rapports sont consultables par le Chef d'Exploitation et le Chef de Base.
    **Implémentation** : Génération de PDF pour les fiches de manœuvre et les attestations de travail.

## Épic 8 : Authentification et Sécurité (Priorité Haute) - ✅ PARTIELLEMENT COMPLÉTÉ

26. **US026 - Connexion/Déconnexion** ✅  
    *En tant qu'utilisateur, je veux me connecter/déconnecter au système.*  
    **Critères d'acceptation** :
    - Formulaire de connexion avec identifiant/mot de passe.
    - Gestion des sessions (expiration après inactivité).
    **Implémentation** : Authentification JWT avec expiration de session et stockage sécurisé.

27. **US027 - Gestion des mots de passe** ⚠️  
    *En tant qu'utilisateur, je veux réinitialiser mon mot de passe en cas d'oubli.*  
    **Critères d'acceptation** : Lien "Mot de passe oublié" avec envoi d'un email de réinitialisation.
    **À implémenter** : Fonctionnalité de réinitialisation de mot de passe par email.

28. **US028 - Contrôle des permissions** ✅  
    *En tant qu'administrateur, je veux attribuer des permissions spécifiques aux rôles.*  
    **Critères d'acceptation** : Interface d'administration pour gérer les accès (ex : Chef de Base ne peut pas valider ses propres notes d'arrêt).
    **Implémentation** : Système complet de contrôle d'accès basé sur les rôles (RBAC) avec vérifications côté client et serveur.