import { Heart, HeartHandshake, Stethoscope, Truck } from "lucide-react";

const roles = [
  {
    name: "Résident",
    description:
      "Reste en lien avec ses proches, suit son agenda et accède aux services de l'établissement.",
    icon: Heart,
    color: "#8C68D5",
    bg: "#F3EEFC",
  },
  {
    name: "Famille",
    description:
      "Suit le quotidien de son proche, échange avec l'équipe et réserve des prestations.",
    icon: HeartHandshake,
    color: "#E75E9D",
    bg: "#FCEBF2",
  },
  {
    name: "Professionnel",
    description:
      "Communique avec les familles, partage des photos et gère l'agenda des résidents.",
    icon: Stethoscope,
    color: "#59B37D",
    bg: "#EAF6EF",
  },
  {
    name: "Prestataire",
    description:
      "Reçoit les réservations, gère son planning et propose ses services aux résidences.",
    icon: Truck,
    color: "#F6A53A",
    bg: "#FDF2E4",
  },
];

export function Roles() {
  return (
    <section id="roles" className="mx-auto max-w-6xl px-6 py-24">
      <div className="mx-auto max-w-2xl text-center">
        <h2 className="text-3xl font-bold sm:text-4xl">Pensé pour chaque profil</h2>
        <p className="mt-4 text-text-muted">
          Une expérience adaptée à chacun, avec le même fil conducteur : rester
          proche de l&apos;essentiel.
        </p>
      </div>
      <div className="mt-14 grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
        {roles.map(({ name, description, icon: Icon, color, bg }) => (
          <div
            key={name}
            className="rounded-card border border-border bg-surface p-6 shadow-soft transition hover:-translate-y-1"
          >
            <div
              className="flex h-12 w-12 items-center justify-center rounded-full"
              style={{ backgroundColor: bg }}
            >
              <Icon size={22} strokeWidth={2} color={color} />
            </div>
            <h3 className="mt-5 text-lg font-semibold text-title">{name}</h3>
            <p className="mt-2 text-sm text-text-muted">{description}</p>
          </div>
        ))}
      </div>
    </section>
  );
}
