import {
  Bell,
  Calendar,
  CalendarCheck,
  Camera,
  MessageCircle,
  Recycle,
  ShieldCheck,
  UserCircle,
} from "lucide-react";

const features = [
  {
    title: "Connexion sécurisée",
    description: "Un accès simple et protégé, adapté à chaque rôle.",
    icon: ShieldCheck,
  },
  {
    title: "Profils multi-rôles",
    description: "Résident, famille, professionnel, prestataire, admin.",
    icon: UserCircle,
  },
  {
    title: "Messagerie",
    description: "Restez en contact avec vos proches et l'équipe.",
    icon: MessageCircle,
  },
  {
    title: "Photos",
    description: "Partagez les moments du quotidien en toute simplicité.",
    icon: Camera,
  },
  {
    title: "Agenda partagé",
    description: "Rendez-vous, activités et visites, toujours à jour.",
    icon: Calendar,
  },
  {
    title: "Réservation de services",
    description: "Coiffeur, esthétique, animations, prestataires locaux.",
    icon: CalendarCheck,
  },
  {
    title: "Notifications",
    description: "Confirmations, rappels et suivi de statut en temps réel.",
    icon: Bell,
  },
  {
    title: "Seconde vie",
    description: "Don, vente ou location de matériel entre résidences.",
    icon: Recycle,
  },
];

export function Features() {
  return (
    <section className="bg-surface-alt py-24">
      <div className="mx-auto max-w-6xl px-6">
        <div className="mx-auto max-w-2xl text-center">
          <h2 className="text-3xl font-bold sm:text-4xl">
            Tout ce qu&apos;il faut, rien de superflu
          </h2>
          <p className="mt-4 text-text-muted">
            Le noyau fonctionnel du MVP Essencia &amp; Co.
          </p>
        </div>
        <div className="mt-14 grid gap-5 sm:grid-cols-2 lg:grid-cols-4">
          {features.map(({ title, description, icon: Icon }) => (
            <div
              key={title}
              className="rounded-card bg-surface p-5 shadow-soft"
            >
              <Icon size={20} strokeWidth={2} className="text-primary" />
              <h3 className="mt-4 text-sm font-semibold text-title">
                {title}
              </h3>
              <p className="mt-1 text-sm text-text-muted">{description}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
