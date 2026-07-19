import Image from "next/image";

export function Footer() {
  return (
    <footer className="border-t border-border bg-surface py-6">
      <div className="mx-auto flex max-w-6xl flex-wrap items-center justify-between gap-[18px] px-6 text-base text-text-muted">
        <div className="flex items-center gap-[11px]">
          <Image
            src="/logo.png"
            alt="E-sensya & Co"
            width={34}
            height={34}
            className="rounded-[11px]"
          />
          <span className="font-heading font-bold text-title">E-sensya &amp; Co</span>
        </div>
        <p>Le lien qui prend soin de l&apos;essentiel.</p>
        <p>&copy; {new Date().getFullYear()} E-sensya &amp; Co. Tous droits réservés.</p>
      </div>
    </footer>
  );
}
