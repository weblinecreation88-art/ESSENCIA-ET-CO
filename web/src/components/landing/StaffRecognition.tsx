import Image from "next/image";
import { Award, Crown, Lock, MessageCircleHeart } from "lucide-react";

const points = [
  {
    title: "Feedback bienveillant",
    description:
      "Résidents et familles notent le personnel en un geste, de façon anonyme et sans jugement.",
    icon: MessageCircleHeart,
    color: "#e75e9d",
    tint: "#fceff5",
  },
  {
    title: "Notes 100% confidentielles",
    description:
      "Seul l'administrateur de l'établissement consulte les résultats — jamais entre collègues.",
    icon: Lock,
    color: "#8c68d5",
    tint: "#f3eefc",
  },
  {
    title: "Récompenses à la clé",
    description:
      "Chèques cadeaux, primes ou attentions personnalisées pour valoriser les meilleurs efforts.",
    icon: Award,
    color: "#f6a53a",
    tint: "#fdf2e4",
  },
  {
    title: "Employé du mois",
    description:
      "Un classement clair pour mettre en lumière, mois après mois, les talents qui font la différence.",
    icon: Crown,
    color: "#59b37d",
    tint: "#eaf6ef",
  },
];

export function StaffRecognition() {
  return (
    <section className="bg-surface-alt py-24">
      <div className="mx-auto max-w-6xl px-6">
        <div className="grid items-center gap-16 lg:grid-cols-[0.85fr_1.15fr]">
          <div className="relative mx-auto w-full max-w-[340px]">
            <div
              className="absolute -inset-x-[8%] -inset-y-[8%] rotate-3 rounded-[40px]"
              style={{ background: "linear-gradient(150deg,#f3eefc,#fbeaf3)" }}
            />
            <Image
              src="/illustrations/staff-reward.png"
              alt="Une membre du personnel récompensée par un chèque cadeau, illustration E-sensya & Co"
              width={994}
              height={994}
              className="relative block w-full rounded-[32px] shadow-[0_26px_56px_rgba(70,40,120,0.14)]"
            />
            <div className="absolute -right-6 bottom-8 flex items-center gap-3 rounded-[18px] border border-border bg-surface px-4 py-3 shadow-[0_16px_36px_rgba(70,40,120,0.16)]">
              <span className="flex h-10 w-10 flex-none items-center justify-center rounded-xl bg-[#fdf2e4]">
                <Award size={20} className="text-[#f6a53a]" />
              </span>
              <div>
                <p className="text-[0.72rem] font-semibold uppercase tracking-wide text-text-muted">
                  Ce mois-ci
                </p>
                <p className="text-[0.92rem] font-semibold text-title">Employée du mois 🏆</p>
              </div>
            </div>
          </div>

          <div>
            <span className="text-sm font-bold uppercase tracking-[0.08em] text-primary">
              Reconnaissance &amp; motivation
            </span>
            <h2 className="mt-3.5 text-[clamp(2rem,3.4vw,2.7rem)] font-extrabold tracking-[-0.02em]">
              Un personnel qui se sent vu, valorisé, remercié
            </h2>
            <p className="mt-4 max-w-xl text-lg leading-relaxed text-text-muted">
              Chaque avis laissé par un résident ou une famille aide votre établissement à
              repérer les talents qui font la différence au quotidien — dans la discrétion
              la plus totale.
            </p>

            <div className="mt-10 grid gap-[18px] sm:grid-cols-2">
              {points.map(({ title, description, icon: Icon, color, tint }) => (
                <div key={title} className="flex items-start gap-3.5">
                  <span
                    className="flex h-11 w-11 flex-none items-center justify-center rounded-[14px]"
                    style={{ backgroundColor: tint }}
                  >
                    <Icon size={20} strokeWidth={2} color={color} />
                  </span>
                  <div>
                    <h3 className="text-[1.02rem] font-bold text-title">{title}</h3>
                    <p className="mt-1 text-[0.92rem] leading-relaxed text-text-muted">
                      {description}
                    </p>
                  </div>
                </div>
              ))}
            </div>

            <div className="mt-8 flex items-center gap-3 rounded-[18px] border border-border bg-surface px-5 py-4">
              <Lock size={18} strokeWidth={2.2} className="flex-none text-primary" />
              <p className="text-[0.94rem] font-semibold text-title">
                Notes privées &amp; équitables — vous seul(e) décidez qui récompenser et
                comment.
              </p>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
