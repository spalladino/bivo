class Symbol

  def description
    if self == :active
      return _("active")

    elsif self == :inactive
      return _("pending approval")

    elsif self == :raising_funds
      return _("raising funds")

    elsif self == :completed
      return _("completed")

    elsif self == :deleted
      return _("deleted")

    else self.to_s

    end
  end
end

