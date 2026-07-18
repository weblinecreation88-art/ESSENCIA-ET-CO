import { Heart, Stethoscope, Truck, Users } from "lucide-react";

const roles = [
  {
    num: "01",
    name: "Résident",
    description:
      "Reste en lien avec ses proches, suit son agenda et accède aux services de l'établissement.",
    icon: Heart,
    color: "#8c68d5",
    numColor: "#e2d6f7",
    bar: "linear-gradient(90deg,#8c68d5,#bca8e7)",
    tint: "linear-gradient(145deg,#f3eefc,#e8ddf9)",
    hoverShadow: "hover:shadow-[0_26px_52px_rgba(140,104,213,0.2)]",
  },
  {
    num: "02",
    name: "Famille",
    description:
      "Suit le quotidien de son proche, échange avec l'équipe et réserve des prestations.",
    icon: Users,
    color: "#e75e9d",
    numColor: "#f7cbdf",
    bar: "linear-gradient(90deg,#e75e9d,#f4a6c8)",
    tint: "linear-gradient(145deg,#fceff5,#f9dfec)",
    hoverShadow: "hover:shadow-[0_26px_52px_rgba(231,94,157,0.2)]",
  },
  {
    num: "03",
    name: "Professionnel",
    description:
      "Communique avec les familles, partage des photos et gère l'agenda des résidents.",
    icon: Stethoscope,
    color: "#59b37d",
    numColor: "#bfe6cf",
    bar: "linear-gradient(90deg,#59b37d,#93d1ac)",
    tint: "linear-gradient(145deg,#eaf6ef,#d8efe1)",
    hoverShadow: "hover:shadow-[0_26px_52px_rgba(89,179,125,0.2)]",
  },
  {
    num: "04",
    name: "Prestataire",
    description:
      "Reçoit les réservations, gère son planning et propose ses services aux résidences.",
    icon: Truck,
    color: "#f6a53a",
    numColor: "#fbdcb2",
    bar: "linear-gradient(90deg,#f6a53a,#fbc987)",
    tint: "linear-gradient(145deg,#fdf2e4,#fbe6cd)",
    hoverShadow: "hover:shadow-[0_26px_52px_rgba(246,165,58,0.22)]",
  },
];

export function Roles() {
  return (
    <section id="roles" className="mx-auto max-w-6xl px-6 py-24">
      <div className="mx-auto flex max-w-xl flex-col gap-4 text-center">
        <span className="text-sm font-bold uppercase tracking-[0.08em] text-primary">
          Pour qui
        </span>
        <h2 className="text-[clamp(2rem,3.4vw,2.7rem)] font-extrabold tracking-[-0.02em]">
          Pensé pour chaque profil
        </h2>
        <p className="text-lg leading-relaxed text-text-muted">
          Une expérience adaptée à chacun, avec le même fil conducteur : rester proche de
          l&apos;essentiel.
        </p>
      </div>
      <div className="mt-14 grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
        {roles.map(
          ({ num, name, description, icon: Icon, color, numColor, bar, tint, hoverShadow }) => (
            <div
              key={name}
              className={`relative overflow-hidden rounded-[24px] border border-border bg-surface px-7 py-[30px] shadow-[0_10px_30px_rgba(70,40,120,0.06)] transition-all duration-300 hover:-translate-y-2 ${hoverShadow}`}
            >
              <div className="absolute inset-x-0 top-0 h-1" style={{ background: bar }} />
              <div className="flex items-start justify-between">
                <span
                  className="flex h-[58px] w-[58px] items-center justify-center rounded-[17px]"
                  style={{ background: tint }}
                >
                  <Icon size={27} strokeWidth={2} color={color} />
                </span>
                <span
                  className="font-heading text-[1.05rem] font-extrabold"
                  style={{ color: numColor }}
                >
                  {num}
                </span>
              </div>
              <h3 className="mt-[22px] text-[1.22rem] font-bold text-title">{name}</h3>
              <p className="mt-2.5 text-base leading-[1.55] text-text-muted">{description}</p>
            </div>
          ),
        )}
      </div>
    </section>
  );
}
