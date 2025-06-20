# Les besoins fonctionnels

Ce sont des besoins qui se rapportent aux fonctionnalités que notre application doit fournir pour répondre aux exigences de l'utilisateur :

## 1. Chef d'exploitation

- **Création de notes d'arrêt** : L'application doit permettre au chef d'exploitation de créer des notes d'arrêt en remplissant un formulaire détaillé, incluant des informations sur l'ouvrage électrique et le chargé d'exploitation concerné.

- **Modification des notes d'arrêt** : En cas de rejet, le chef d'exploitation doit pouvoir modifier la note d'arrêt et la renvoyer pour validation.

- **Suivi des consignations** : Un tableau de bord en temps réel doit être disponible pour suivre l'avancement des consignations et recevoir des alertes en cas de retard ou d'incident.

- **Notifications** : Le chef d'exploitation doit recevoir des notifications lorsque les notes d'arrêt sont validées, rejetées ou modifiées.

## 2. Chef de Base

- **Validation des notes d'arrêt** : L'application doit permettre au Chef de Base de visualiser les notes d'arrêt en attente de validation, de les approuver ou de les rejeter avec des motifs de rejet.

- **Notifications** : Le Chef de Base doit être notifié lorsqu'une nouvelle note d'arrêt est émise par le chef d'exploitation.

- **Suivi des notes d'arrêt** : Un aperçu des notes d'arrêt validées, rejetées ou en attente doit être disponible.

## 3. Chargé d'exploitation

- **Réception des notes d'arrêt** : L'application doit afficher les notes d'arrêt validées dans l'interface du chargé d'exploitation, avec la possibilité de confirmer leur réception.

- **Désignation du chargé de consignation** : Le chargé d'exploitation doit pouvoir désigner un chargé de consignation pour chaque note d'arrêt validée.

- **Vérification des fiches de manœuvre** : Le chargé d'exploitation doit pouvoir accéder aux fiches de manœuvre générées, les vérifier et les valider.

- **Notifications** : Le chargé d'exploitation doit être notifié lorsque la consignation est validée ou en cas d'incident.

## 4. Chargé de consignation

- **Initiation des consignations** : L'application doit permettre au chargé de consignation de démarrer une nouvelle consignation en sélectionnant un ouvrage HT et une procédure correspondante, avec génération automatique d'un numéro de consignation unique.

- **Suivi des étapes de consignation** : Le chargé de consignation doit pouvoir suivre les étapes prédéfinies de la consignation et enregistrer la durée de chaque étape.

- **Notifications en cas d'incident** : Le chargé de consignation doit émettre des notifications push en temps réel en cas d'anomalie ou d'incident.

- **Début et fin des travaux** : Le chargé de consignation doit pouvoir marquer le début des travaux une fois la consignation validée et valider la fin des travaux avant de démarrer la déconsignation.

- **Délivrance des attestations** : Le chargé de consignation doit pouvoir délivrer des attestations de consignation (N° de l'attestation) aux intervenants externes.

- **Gestion des modèles** : Le chargé de consignation doit pouvoir créer, modifier et supprimer des modèles de consignation et de déconsignation, ainsi qu'ajouter des schémas unifilaires.

## 5. Administrateur

- **Gestion des intervenants** : L'application doit permettre à l'administrateur de créer, modifier, désactiver ou supprimer des intervenants, avec la possibilité d'attribuer des permissions spécifiques.