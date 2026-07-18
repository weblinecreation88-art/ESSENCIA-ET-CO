import Image from "next/image";
import { Check } from "lucide-react";

const trust = ["Conforme RGPD", "Sans engagement", "Accompagnement inclus"];

export function Cta() {
  return (
    <section id="contact" className="mx-auto max-w-6xl px-6 py-24">
      <div
        className="relative overflow-hidden rounded-[32px] shadow-[0_30px_70px_rgba(111,73,200,0.35)]"
        style={{
          background: "linear-gradient(135deg,#9b74e7 0%,#845dd7 50%,#6f49c8 100%)",
        }}
      >
        <div className="absolute -right-10 -top-20 h-80 w-80 rounded-full bg-white/10" />
        <div className="absolute -bottom-32 -left-16 h-[340px] w-[340px] rounded-full bg-[rgba(231,94,157,0.22)]" />
        <div className="relative grid items-center gap-12 p-[64px_60px] lg:grid-cols-[1.25fr_1fr]">
          <div>
            <h2 className="text-[clamp(1.9rem,3.2vw,2.6rem)] font-extrabold leading-[1.2] tracking-[-0.02em] text-white">
              Prêt à tester Essencia &amp; Co dans votre établissement ?
            </h2>
            <p className="mt-[18px] max-w-xl text-lg leading-relaxed text-white/[0.92]">
              Nous lançons un pilote avec quelques établissements pour valider le noyau
              fonctionnel. Parlons de votre structure et de vos besoins.
            </p>
            <div className="mt-8 flex flex-wrap gap-3.5">
              <a
                href="mailto:contact@essencia-co.fr?subject=Demande%20de%20pilote%20Essencia%20%26%20Co"
                className="rounded-[16px] bg-white px-7 py-[15px] text-[1.05rem] font-bold text-primary-dark shadow-[0_12px_30px_rgba(0,0,0,0.16)] transition hover:-translate-y-0.5 hover:text-primary active:scale-95"
              >
                Demander une démo pilote
              </a>
              <a
                href="mailto:contact@essencia-co.fr"
                className="rounded-[16px] border border-white/40 bg-white/[0.12] px-7 py-[15px] text-[1.05rem] font-semibold text-white transition hover:bg-white/20 active:scale-95"
              >
                Nous écrire
              </a>
            </div>
            <div className="mt-[26px] flex flex-wrap gap-5 text-[0.96rem] text-white/90">
              {trust.map((label) => (
                <span key={label} className="inline-flex items-center gap-2">
                  <Check size={18} strokeWidth={2.2} /> {label}
                </span>
              ))}
            </div>
          </div>
          <div className="mx-auto w-full max-w-[290px]">
            <Image
              src="/illustrations/caregivers-wheelchair.png"
              alt="Deux aidants accompagnant une résidente, illustration Essencia & Co"
              width={800}
              height={800}
              className="block w-full rounded-[24px] shadow-[0_20px_44px_rgba(0,0,0,0.2)]"
            />
          </div>
        </div>
      </div>
    </section>
  );
}
