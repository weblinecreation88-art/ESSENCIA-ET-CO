import Image from "next/image";

export function Footer() {
  return (
    <footer className="border-t border-border bg-surface py-10">
      <div className="mx-auto flex max-w-6xl flex-col items-center justify-between gap-4 px-6 text-sm text-text-muted sm:flex-row">
        <div className="flex items-center gap-2">
          <Image src="/logo.png" alt="Essencia & Co" width={28} height={28} className="rounded-field" />
          <span className="font-heading font-semibold text-title">
            Essencia &amp; Co
          </span>
        </div>
        <p>Le lien qui prend soin de l&apos;essentiel.</p>
        <p>&copy; {new Date().getFullYear()} Essencia &amp; Co. Tous droits réservés.</p>
      </div>
    </footer>
  );
}
