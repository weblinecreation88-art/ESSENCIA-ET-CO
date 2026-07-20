import Image from "next/image";
import { Bell, Check, Download, MessageCircle } from "lucide-react";

const APK_DOWNLOAD_URL =
  "https://drive.google.com/file/d/1lfS4-i6o_WupghispnntlQdX7fiB9L5-/view?usp=drive_link";

export function Hero() {
  return (
    <section id="top" className="relative overflow-hidden">
      {/* Soft decorative blobs */}
      <div className="pointer-events-none absolute inset-0 overflow-hidden">
        <div
          className="absolute -right-32 -top-40 h-[560px] w-[560px] rounded-full opacity-50 blur-[8px]"
          style={{
            background:
              "radial-gradient(circle at 30% 30%, #c9b4f0, #a583e6 60%, transparent 72%)",
          }}
        />
        <div
          className="absolute -left-36 top-32 h-[420px] w-[420px] rounded-full opacity-[0.55]"
          style={{
            background: "radial-gradient(circle at 50% 50%, #f6c9de, transparent 70%)",
          }}
        />
        <div
          className="absolute -bottom-32 left-[40%] h-[380px] w-[380px] rounded-full opacity-45"
          style={{ background: "radial-gradient(circle, #cdeede, transparent 70%)" }}
        />
      </div>

      <div className="relative mx-auto grid max-w-6xl items-center gap-16 px-6 pb-24 pt-[76px] lg:grid-cols-[1.05fr_0.95fr]">
        <div className="flex flex-col items-start gap-[26px]">
          <span className="inline-flex items-center gap-[9px] rounded-full border border-border bg-surface px-4 py-2 text-sm font-semibold text-primary-dark shadow-[0_6px_18px_rgba(70,40,120,0.07)]">
            <span className="h-2 w-2 rounded-full bg-success shadow-[0_0_0_4px_rgba(89,179,125,0.18)]" />
            EHPAD &amp; résidences seniors
          </span>
          <h1 className="text-[clamp(2.6rem,5vw,4rem)] font-extrabold tracking-[-0.025em] text-title">
            Le lien qui prend soin de{" "}
            <span
              className="text-primary"
              style={{
                background: "linear-gradient(120deg, #9b74e7, #e75e9d)",
                WebkitBackgroundClip: "text",
                backgroundClip: "text",
                WebkitTextFillColor: "transparent",
              }}
            >
              l&apos;essentiel
            </span>
          </h1>
          <p className="max-w-xl text-[clamp(1.12rem,1.6vw,1.28rem)] leading-relaxed text-text">
            E-sensya &amp; Co rapproche résidents, familles, équipes et prestataires :
            messagerie, agenda, réservation de services et notifications, réunis dans
            une application simple et rassurante.
          </p>
          <div className="flex flex-wrap gap-3.5 pt-1">
            <a
              href="#contact"
              className="rounded-[16px] bg-primary px-7 py-[15px] text-[1.05rem] font-semibold text-white shadow-[0_12px_30px_rgba(140,104,213,0.34)] transition hover:bg-primary-dark active:scale-95"
            >
              Demander une démo pilote
            </a>
            <a
              href="#apercu"
              className="rounded-[16px] border border-[#e6ddf6] bg-surface px-7 py-[15px] text-[1.05rem] font-semibold text-primary-dark shadow-[0_8px_22px_rgba(70,40,120,0.06)] transition hover:border-primary-soft active:scale-95"
            >
              Découvrir l&apos;application
            </a>
          </div>
          <a
            href={APK_DOWNLOAD_URL}
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex items-center gap-2 text-[0.98rem] font-semibold text-primary-dark transition hover:text-primary"
          >
            <Download size={18} strokeWidth={2.2} />
            Télécharger l&apos;APK Android (bêta, avant le Play Store)
          </a>
          <div className="flex flex-wrap gap-[22px] pt-3.5 text-base text-text-muted">
            {["Conçu pour rassurer", "Accessible aux seniors", "Données sécurisées"].map(
              (label) => (
                <span key={label} className="inline-flex items-center gap-2">
                  <Check size={19} strokeWidth={2.2} className="text-success" />
                  {label}
                </span>
              ),
            )}
          </div>
        </div>

        <div className="relative mx-auto w-full max-w-md">
          <div
            className="absolute -inset-x-[4%] -inset-y-[6%] -rotate-3 rounded-[40px] shadow-[0_30px_70px_rgba(70,40,120,0.14)]"
            style={{ background: "linear-gradient(150deg, #efe7fb, #fbeaf3)" }}
          />
          <Image
            src="/illustrations/hero-family.png"
            alt="Une résidente entourée de sa famille, illustration E-sensya & Co"
            width={1200}
            height={1200}
            className="relative block w-full rounded-[32px]"
            priority
          />
          <div className="absolute -left-6 top-5 flex animate-[float_6s_ease-in-out_infinite] items-center gap-3 rounded-[18px] border border-border bg-surface px-4 py-3 shadow-[0_16px_36px_rgba(70,40,120,0.16)]">
            <span className="flex h-10 w-10 flex-none items-center justify-center rounded-xl bg-[#f3eefc]">
              <Bell size={20} className="text-primary" />
            </span>
            <div>
              <p className="text-[0.72rem] font-semibold uppercase tracking-wide text-text-muted">
                Rappel
              </p>
              <p className="text-[0.92rem] font-semibold text-title">Coiffeur — 14h30</p>
            </div>
          </div>
          <div className="absolute -right-6 bottom-6 flex animate-[float2_7s_ease-in-out_infinite] items-center gap-3 rounded-[18px] border border-border bg-surface px-4 py-3 shadow-[0_16px_36px_rgba(70,40,120,0.16)]">
            <span className="flex h-10 w-10 flex-none items-center justify-center rounded-xl bg-[#fceff5]">
              <MessageCircle size={20} className="text-secondary" />
            </span>
            <div>
              <p className="text-[0.72rem] font-semibold uppercase tracking-wide text-text-muted">
                Message
              </p>
              <p className="text-[0.92rem] font-semibold text-title">Julie a écrit ♥</p>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
