# This Fact handles determining if marklogic is available via yum
module Facter::Util::MarklogicPackage
  class << self

    # Return the repository name that contains a MarkLogic package
    def get_marklogic_repository
      $package = 'MarkLogic';
      $marklogic_repository = Facter::Util::Resolution.exec("yum provides #{$package} 2>/dev/null | grep #{$package} -A 1 | grep -E 'Repo\s+?:' | grep -v installed | awk '{print $3}'");
      return $marklogic_repository
    end

    # Return a true or false value if MarkLogic is available via yum
    def is_marklogic_available
      config = get_marklogic_repository;
      if (config == nil || config.empty?) 
        return false;
      end
      return true;
    end

  end
end

# Return a true or false value if MarkLogic is available via yum
Facter.add(:is_marklogic_available) do
  setcode {
    Facter::Util::MarklogicPackage.is_marklogic_available;
  }
end
